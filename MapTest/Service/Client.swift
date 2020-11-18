//
//  Client.swift
//  MapTest
//
//  Created by Maksim Kalik on 18/11/2020.
//
// I got this snipet from here: https://developer.apple.com/forums/thread/116723
// I like the code for organization and scalability
// This example uses Network framework

import Foundation
import Network

// I suggest to use delegation for this case
// we will delegate user list and updates

protocol ClientDelegate: AnyObject {
    func didUpdateUserCoordinates(locations: LocationUpdates)
    func didRecieveUserList(users: [User])
}

class Client {

    private let connection: NWConnection
    weak var delegate: ClientDelegate?
    
    // We initialize this class with hostname and port using tcp
    init(hostName: String, port: Int) {
        let host = NWEndpoint.Host(hostName)
        let port = NWEndpoint.Port("\(port)")!
        connection = NWConnection(host: host, port: port, using: .tcp)
    }

    // MARK: - Connection Methods
    
    func start() {
        print("Starting connection")
        connection.stateUpdateHandler = self.didChange(state:)
        startReceive()
        connection.start(queue: .main)
    }

    func stop() {
        connection.cancel()
        print("Connection did stop")
    }

    // MARK: - Connection states
    
    private func didChange(state: NWConnection.State) {
        switch state {
        case .setup:
            break
        case .waiting(let error):
            print("Is waiting \(error)")
        case .preparing:
            break
        case .ready:
            break
        case .failed(let error):
            print("did fail, error: \(error)")
            self.stop()
        case .cancelled:
            print("Was cancelled")
            self.stop()
        @unknown default:
            break
        }
    }
    
    // MARK: - Receiving data
    
    // Recursion for receving data
    private func startReceive() {
        connection.receive(minimumIncompleteLength: 1, maximumLength: 65536) { data, _, isDone, error in
            if let data: Data = data, !data.isEmpty {
                self.readReceived(data: data)
            }
            if let error = error {
                debugPrint(error.localizedDescription)
                self.stop()
                return
            }
            if isDone {
                print("Did recive End-of-file")
                self.stop()
                return
            }
            // Make self call
            self.startReceive()
        }
    }
    
    // Read receiving data
    private func readReceived(data: Data) {
        guard let rawDataString = String(data: data, encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue)) else { return }
        guard let keyWord = rawDataString.firstWord() else { return }
        switch keyWord {
        case Command.USERLIST:
            let userList = parseUserList(from: rawDataString)
            // Delegate user list to view controller
            self.delegate?.didRecieveUserList(users: userList)
        case Command.UPDATE:
            let locationUpdates = parseUpdatedLocations(from: rawDataString)
            // Delegate updates to view controller
            self.delegate?.didUpdateUserCoordinates(locations: locationUpdates)
        default:
            return
        }
    }

    // MARK: - Send
    
    // Here we will send our comands with a newline character "\n"
    func send(line: String) {
        let data = Data("\(line)\n".utf8)
        self.connection.send(content: data, completion: .contentProcessed { error in
            if let error = error {
                debugPrint(error.localizedDescription)
                self.stop()
            } else {
                print("Data did send: \(data)")
            }
        })
    }
}

//
//  ViewController.swift
//  MapTest
//
//  Created by Maksim Kalik on 18/11/2020.
//

import UIKit
import MapKit

class ViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    
    var users = [User]()
    var annotations = [MKPointAnnotation]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startClient()
    }

    private func startClient() {
        let client = Client(hostName: "ios-test.printful.lv", port: 6111)
        client.start()
        client.send(line: "AUTHORIZE maxkalik@gmail.com")
        client.delegate = self
    }
    
    private func createAnnotatinos(userList: [User]) {
        // Walking through all users and create annotations
        for user in userList {
            // Before creating annotation we should prepare coordinate
            let latitude = user.location.latitude
            let longitude = user.location.longitude
            let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            // Creating annotation
            let annotation = MKPointAnnotation()
            // Set coordinate to annotation
            annotation.coordinate = coordinate
            // Append annotation to annotations
            annotations.append(annotation)
        }
        mapView.addAnnotations(annotations)
        mapView.showAnnotations(mapView.annotations, animated: true)
    }
}

extension ViewController: ClientDelegate {
    
    // initial User List
    func didRecieveUserList(users: [User]) {
        createAnnotatinos(userList: users)
        self.users = users
    }
    
    // Updates
    func didUpdateUserCoordinates(locations: LocationUpdates) {
        // Here we will try to figureout whose coordinate has changed
        for updates in locations {
            // Find a user with the same id which came from updates
            if let index = self.users.firstIndex(where: { $0.id == updates.id }) {
                // Checking the locatoin on difference
                if self.users[index].location != updates.location {
                    // Update user last location
                    self.users[index].location = updates.location
                    print(updates.id, updates.location)
                }
            }
        }
    }
}


//
//  Client+Parsers.swift
//  MapTest
//
//  Created by Maksim Kalik on 18/11/2020.
//

import Foundation

extension Client {
    
    // MARK: Parse USERLIST string to the model
    // User(id: 101, name: Jānis Bērziņš, image: https://i4.ifrype.com/profile/000/324/v1559116100/ngm_324.jpg),
    // location: Location(latitude: 56.9495677035, longitude: 24.1064071655))
    // and append this item to the array. It will be a parsed list of users.
    func parseUserList(from rawString: String) -> [User] {
        
        // Create an instance of Users array
        var userList = [User]()
        
        // Parse the incoming string by removing USERLIST and all characters \n
        let usersString = rawString.removeSubstring("USERLIST")?.removeSubstring("\n")
        
        // Spliting into sequence like ["user string", "user string"]
        let users: [String.SubSequence] = usersString!.bySemicolon
        
        // Walk through this sequence and parse the data into the User Model
        users.forEach { userString in
            // Split the string into the sequence
            let subStringUser: [Substring.SubSequence] = userString.split(separator: ",")
            
            // Create a user instance
            let user: User = User(subString: subStringUser)
            
            // And append it to the userList array
            userList.append(user)
        }
        return userList
    }
    
    
    // MARK: Parse UPDATE string to the model
    
    // We will use an array of tuples with id and location
    // Why tuples - because I want to save an id wich I will use in the future to find the user who is moving
    // (whose coordinate is changing)
    typealias LocationUpdates = [(id: String, location: Location)]
    
    func parseUpdatedLocations(from rawString: String) -> LocationUpdates {
        // Create an instance of LocationUpdates
        var locationUpdates = LocationUpdates()
        
        // Split into sequence by /n
        let lines: [String.SubSequence] = rawString.byLines
        // Create an array with parsed strings
        // ["101", "12.1234456", "12.123456"] <- where first item is an id the rest is coordinate
        let updates: [String] = lines.compactMap { subStr -> String? in
            let updatedSubStr = subStr.removeSubstring("UPDATE")
            return updatedSubStr
        }
        // Walk through this array and parse into the LocationUpdates type
        updates.forEach { updateString in
            // Split the string into the sequence
            let subSrtingUpdate: [Substring.SubSequence] = updateString.split(separator: ",")
            
            // Taking user id
            let userId = String(subSrtingUpdate[0])
            // Preparing coordinate
            guard let latitude = Double(subSrtingUpdate[1]), let longitude = Double(subSrtingUpdate[2]) else { return }
            // Append to locationUpdates the tuples
            locationUpdates.append((id: userId, location: Location(latitude: latitude, longitude: longitude)))
        }
        return locationUpdates
    }
}

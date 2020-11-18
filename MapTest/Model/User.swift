//
//  User.swift
//  MapTest
//
//  Created by Maksim Kalik on 18/11/2020.
//

import Foundation

struct User {
    var id: String
    var name: String
    var image: String
    
    // Initialize location instance
    var location = Location(latitude: 56.9495677035, longitude: 24.1064071655)
    
    // Default init
    init(
        id: String = "",
        name: String = "",
        image: String = ""
    ) {
        self.id = id
        self.name = name
        self.image = image
    }
    
    // Initializer with substring for converting it to model
    init(subString: [Substring.SubSequence]) {
        id = String(subString[0])
        name = String(subString[1])
        image = String(subString[2])
        let latitude = Double(subString[3]) ?? 0.0
        let longitude = Double(subString[4]) ?? 0.0
        location = Location(latitude: latitude, longitude: longitude)
    }
}

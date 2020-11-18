//
//  Annotation.swift
//  MapTest
//
//  Created by Maksim Kalik on 18/11/2020.
//

import MapKit

class Annotation: NSObject, MKAnnotation {
    let id: String?
    let title: String?
    let imageURL: URL?
    // We need to see some changings while using the map
    // MKMapView uses KVO to know when some variables changing
    // so I marked subtitle (address) and coordinate as @objc dynamic
    // to make changing works
    @objc dynamic var subtitle: String?
    @objc dynamic var coordinate: CLLocationCoordinate2D
    
    init(
        id: String?,
        title: String?,
        subtitle: String?,
        imageURL: URL?,
        coordinate: CLLocationCoordinate2D
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.imageURL = imageURL
        self.coordinate = coordinate
        super.init()
    }
}

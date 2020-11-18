//
//  ViewController.swift
//  MapTest
//
//  Created by Maksim Kalik on 18/11/2020.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    
    var users = [User]()
    var annotations = [MKPointAnnotation]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startClient()
    }

    // Begin client connection
    private func startClient() {
        let client = Client(hostName: Settings.hostName, port: Settings.port)
        client.start()
        client.send(line: "\(Command.AUTHORIZE) \(Settings.email)")
        client.delegate = self
    }
    
    // Create annotations and add them to the map
    private func createAnnotatinos(userList: [User]) {
        // Walking through all users and create annotations
        for user in userList {
            let annotation = createAnnotation(for: user)
            annotations.append(annotation)
        }
        mapView.addAnnotations(annotations)
        // Show all annotations and fit them with proper zooming
        mapView.fitAnnotations()
    }
    
    // Create annotation fro a user
    private func createAnnotation(for user: User) -> MKPointAnnotation {
        // Before creating annotation we should prepare coordinate
        let latitude = user.location.latitude
        let longitude = user.location.longitude
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        // Creating annotation
        let annotation = MKPointAnnotation()
        // Set coordinate to annotation
        annotation.coordinate = coordinate
        
        // Look up the current location of the annotation
        lookUpCurrentLocation(latitude: latitude, longitude: longitude) { placemark in
            // Street name
            let street = placemark?.thoroughfare ?? ""
            // Building number
            let building = placemark?.subThoroughfare ?? ""
            print("\(street) \(building)")
        }
        return annotation
    }
    
    // Convert a Coordinate into a Placemark
    // This method I took from this article: https://developer.apple.com/documentation/corelocation/converting_between_coordinates_and_user-friendly_place_names
    private func lookUpCurrentLocation(latitude: CLLocationDegrees, longitude: CLLocationDegrees, completionHandler: @escaping (CLPlacemark?) -> Void ) {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(CLLocation(latitude: latitude, longitude: longitude), completionHandler: { (placemarks, error) in
            if error == nil {
                // Retrieve a CLPlacemark object
                let firstLocation = placemarks?[0]
                completionHandler(firstLocation)
            } else {
                // An error occurred during geocoding.
                completionHandler(nil)
            }
        })
    }
}

// MARK: - ClientDelegate

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
                // (in my case its only user with id 102)
                if self.users[index].location != updates.location {
                    // Update user last location
                    self.users[index].location = updates.location
                    print(updates.id, updates.location)
                }
            }
        }
    }
}

//
//  ViewController.swift
//  MapTest
//
//  Created by Maksim Kalik on 18/11/2020.
//

import UIKit
import MapKit
import CoreLocation

// MARK: - Map Properties

fileprivate let mapInset: CGFloat = 165


// MARK: - HomeVC

class HomeVC: UIViewController {

    @IBOutlet weak var mapView: MKMapView! {
        didSet {
            // Register custom annotation
            mapView.register(AnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
            mapView.delegate = self
        }
    }
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    private var users = [User]()
    private var annotations = [Annotation]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startClient()
        spinner.startAnimating()
        mapView.isHidden = true
    }
    
    // Begin client connection
    private func startClient() {
        let client = Client(hostName: Settings.hostName, port: Settings.port)
        client.start()
        client.send(line: "\(Command.AUTHORIZE) \(Settings.email)")
        client.delegate = self
    }
    
    // MARK: - Map and Annotations
    
    // Create annotations and add them to the map
    private func createAnnotatinos(userList: [User]) {
        // Walking through all users and create annotations
        for user in userList {
            let annotation = createAnnotation(for: user)
            annotations.append(annotation)
        }
        mapView.addAnnotations(annotations)
        // Show all annotations and fit them with proper zooming
        mapView.fitAnnotations(inset: mapInset)
        // Hide spinner and show mapview
        spinner.stopAnimating()
        mapView.isHidden = false
    }
    
    // Create annotation fro a user
    private func createAnnotation(for user: User) -> Annotation {
        // Before creating annotation we should prepare coordinate
        let latitude = user.location.latitude
        let longitude = user.location.longitude
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        // Instantiate annotation with coordinates and user info
        let annotation = Annotation(id: user.id, title: user.name, subtitle: "", imageURL: URL(string: user.image), coordinate: coordinate)
        
        // Look up the current location of the annotation
        lookUpCurrentLocation(latitude: latitude, longitude: longitude) { placemark in
            // Set subtitle with the address
            annotation.subtitle = self.getAddress(from: placemark)
        }
        return annotation
    }
    
    private func updateAnnotation(for id: String, location: Location) {
        if let index = self.annotations.firstIndex(where: { $0.id == id }) {
            // Make annotation movable smoothly
            UIView.animate(withDuration: 0.3) {
                // Set coordinate
                self.annotations[index].coordinate = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
                // and of course change the currect address
                // (see the model Annotation how these variabels can be changed
                self.lookUpCurrentLocation(latitude: location.latitude, longitude: location.longitude) { placemark in
                    self.annotations[index].subtitle = self.getAddress(from: placemark)
                }
            }
        }
    }
    
    // MARK: - CoreLocation
    
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
    
    // Parse the current adress from placemark
    private func getAddress(from placemark: CLPlacemark?) -> String {
        // Street name
        let street = placemark?.thoroughfare ?? ""
        // Building number
        let building = placemark?.subThoroughfare ?? ""
        return "\(street) \(building)"
    }
}

// MARK: - ClientDelegate

extension HomeVC: ClientDelegate {
    
    // Initial User List
    func didRecieveUserList(users: [User]) {
        createAnnotatinos(userList: users)
        self.users = users
    }
    
    typealias LocationUpdate = (id: String, location: Location)
    
    // Updates
    func didUpdateUserCoordinates(locations: LocationUpdates) {
        // Here we will try to figureout whose coordinate has changed
        for updates in locations { findUser(with: updates) }
    }
    
    private func findUser(with updates: LocationUpdate) {
        // Find a user with the same id which came from updates
        if let index = self.users.firstIndex(where: { $0.id == updates.id }) {
            // Checking the locatoin on difference
            // (in my case its only user with id 102)
            if self.users[index].location != updates.location {
                // Update user last location
                self.users[index].location = updates.location
                self.updateAnnotation(for: updates.id, location: updates.location)
            }
        }
    }
}

extension HomeVC: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let view = view as? AnnotationView {
            // Call method in the view when annotation did select
            view.didSelect()
        }
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        if let view = view as? AnnotationView {
            // Call method in the view when annotation did deseleted
            view.didDeselect()
        }
    }
}

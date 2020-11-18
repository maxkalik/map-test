//
//  Extensions.swift
//  MapTest
//
//  Created by Maksim Kalik on 18/11/2020.
//

import Foundation
import MapKit.MKMapView

// MARK: - String

extension StringProtocol {
    // Split a String into the Sequence
    // by separator newline: \n
    var byLines: [SubSequence] { split(whereSeparator: \.isNewline) }
    // by separator semicolon
    var bySemicolon: [SubSequence] { split(separator: ";")}
    
    // Return first word string from the string
    func firstWord() -> String? {
        return self.components(separatedBy: " ").first
    }
    
    // Remove substring from the string
    func removeSubstring(_ substring: String) -> String? {
        // Replacing solution+ + trim whitespaces
        self.replacingOccurrences(of: substring, with: "").trimmingCharacters(in: .whitespaces)
    }
}

// MARK: - Map View

extension MKMapView {
    // We will call this method when all anotations will in the map view
    func fitAnnotations() {
        // Create a null map rectangle
        var zoomRect = MKMapRect.null;
        // Walk through all annotations for taking all coordinates and caclulate zoomRect
        for annotation in annotations {
            let annotationPoint = MKMapPoint(annotation.coordinate)
            let pointRect = MKMapRect(x: annotationPoint.x, y: annotationPoint.y, width: 0.01, height: 0.01);
            // Combine rectangles
            zoomRect = zoomRect.union(pointRect);
        }
        // And change the visible part of the map
        setVisibleMapRect(zoomRect, edgePadding: UIEdgeInsets(top: 165, left: 165, bottom: 165, right: 165), animated: true)
    }
}

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
        return components(separatedBy: " ").first
    }
    
    // Remove substring from the string
    func removeSubstring(_ substring: String) -> String? {
        // Replacing solution+ + trim whitespaces
        replacingOccurrences(of: substring, with: "").trimmingCharacters(in: .whitespaces)
    }
}

// MARK: - Map View

extension MKMapView {
    // We will call this method when all anotations will in the map view
    func fitAnnotations(inset: CGFloat) {
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
        setVisibleMapRect(zoomRect, edgePadding: UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset), animated: true)
    }
}

// MARK: - UIImageView

extension UIImageView {
    // Convert url into the data
    func load(url: URL) {
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.image = image
                    }
                }
            }
        }
    }
}

// MARK: - UIImage

extension UIImage {
    // Draw circle with color
    class func circle(diameter: CGFloat, color: UIColor) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(CGSize(width: diameter, height: diameter), false, 0)
        // Return the current graphics context (width, height, bpc, bpp, row bytes -> from UIGraphicsBeginImageContextWithOptions()
        let currenctGraphContext = UIGraphicsGetCurrentContext()!
        currenctGraphContext.saveGState()
        
        // create a rect where we put an image
        let rect = CGRect(x: .zero, y: .zero, width: diameter, height: diameter)
        currenctGraphContext.setFillColor(color.cgColor)
        currenctGraphContext.fillEllipse(in: rect)
        
        // Sets the current graphics state to the state most recently saved
        // Core Graphics removes the graphics state at the top of the stack so that the most recently saved state becomes the current graphics state
        currenctGraphContext.restoreGState()
        // Returns an image based on the contents of the current bitmap-based graphics context.
        let img = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return img
    }
    
    func circularImageWithBorderOf(color: UIColor, diameter: CGFloat, boderWidth: CGFloat) -> UIImage {
        let aRect = CGRect.init(x: 0, y: 0, width: diameter, height: diameter)
        UIGraphicsBeginImageContextWithOptions(aRect.size, false, scale)
        
        color.setFill()
        UIBezierPath.init(ovalIn: aRect).fill()
        
        let anInteriorRect = CGRect.init(x: boderWidth, y: boderWidth, width: diameter-2*boderWidth, height: diameter-2*boderWidth)
        UIBezierPath.init(ovalIn: anInteriorRect).addClip()
        
        draw(in: anInteriorRect)
        
        let img = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return img
    }
}

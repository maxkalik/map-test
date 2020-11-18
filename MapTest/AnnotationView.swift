//
//  AnnotationView.swift
//  MapTest
//
//  Created by Maksim Kalik on 18/11/2020.
//

import MapKit

// MARK: - Annotation Properties

// Pin properties

fileprivate let pinBody = #colorLiteral(red: 0.6880982524, green: 0.08848398251, blue: 0.4589408179, alpha: 1)
fileprivate let pinBorder = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
fileprivate let pinDiameter: CGFloat = 20.00
fileprivate let pinDiameterWhenTapped: CGFloat = 10.00
fileprivate let pinBorderWidth: CGFloat = 3

// Bubble properties

fileprivate let imageWidth = 38
fileprivate let imageHeight = 38
fileprivate let imageCornerRadius: CGFloat = 5.0

// General Annotation Properties

fileprivate let shadowOpacity: Float = 0.5
fileprivate let shadowRadius: CGFloat = 8
fileprivate let shadowColor: CGColor = pinBody.cgColor

// MARK: - Annotation View

class AnnotationView: MKAnnotationView {
    
    private let pinImage = UIImage.circle(diameter: pinDiameter, color: pinBody)
    
    override var annotation: MKAnnotation? {
        willSet {
            guard let customAnnotation = newValue as? Annotation else { return }
            
            // The point where the bubble will appear over the pin
            calloutOffset = CGPoint(x: -5, y: -8)
            
            // User image view
            let imageSize = CGSize(width: imageWidth, height: imageHeight)
            let imageView = UIImageView(frame: CGRect(origin: .zero, size: imageSize))
            imageView.layer.cornerRadius = imageCornerRadius
            imageView.layer.masksToBounds = true
            imageView.load(url: customAnnotation.imageURL!)
            
            // set image view in the left callout accessory view
            leftCalloutAccessoryView = imageView
            
            // Shadow
            layer.shadowColor = UIColor.black.cgColor
            layer.shadowOffset = .zero
            
            makeInitialView()
        }
    }
    
    private func makeInitialView() {
        // Pin
        image = pinImage.circularImageWithBorderOf(color: pinBorder, diameter: pinDiameter, boderWidth: pinBorderWidth)
        
        // Shadow
        layer.shadowOpacity = shadowOpacity
        layer.shadowRadius = shadowRadius
    }
    
    func didSelect() {
        image = UIImage.circle(diameter: pinDiameterWhenTapped, color: pinBody)
        layer.shadowOpacity = shadowOpacity - 2
        layer.shadowRadius = shadowRadius + 4
    }
    
    func didDeselect() {
        makeInitialView()
    }
}

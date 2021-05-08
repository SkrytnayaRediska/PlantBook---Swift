//
//  PlantMarkerView.swift
//  laba1
//
//  Created by Ольга Ерохина on 5/8/21.
//

import MapKit


//class PlantMarkerView: MKMarkerAnnotationView {
//    override var annotation: MKAnnotation? {
//        willSet {
//            guard let plant = newValue as? PlantAnnotation else {
//                return
//            }
//            
//            canShowCallout = true
//            calloutOffset = CGPoint(x: -5, y: 5)
//            rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
//            
//            markerTintColor = plant.markerTintColor
//            if let letter = plant.discipline?.first {
//                glyphImage = plant.image
//            }
//        }
//    }
//}


class PlantMarkerView: MKAnnotationView {
    override var annotation: MKAnnotation? {
        willSet {
            guard let plant = newValue as? PlantAnnotation else {
                return
            }
            
            canShowCallout = true
            calloutOffset = CGPoint(x: -5, y: 5)
            rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            
            image = plant.image
        }
    }
}

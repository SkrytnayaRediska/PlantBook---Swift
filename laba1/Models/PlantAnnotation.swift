//
//  PlantAnnotation.swift
//  laba1
//
//  Created by Ольга Ерохина on 5/7/21.
//

import MapKit

class PlantAnnotation: NSObject, MKAnnotation {
    let title: String?
    let subtitle: String?
    let discipline: String?
    let coordinate: CLLocationCoordinate2D
    let plantItem: Plant?
//    var markerTintColor: UIColor {
//        switch discipline {
//        case "Monument":
//            return .red
//        case "Mural":
//            return .cyan
//        case "Plaque":
//            return .blue
//        case "Sculpture":
//            return .purple
//        default:
//            return .green
//        }
//    }
    
    var image: UIImage {
            return #imageLiteral(resourceName: "iconMapTEST1")
    }
    
    
    init(title: String?, subtitle: String?, discipline: String?, coordinate: CLLocationCoordinate2D, plantItem: Plant) {
        self.title = title
        self.subtitle = subtitle
        self.discipline = discipline
        self.coordinate = coordinate
        self.plantItem = plantItem
        
        super.init()
    }
    
    
}

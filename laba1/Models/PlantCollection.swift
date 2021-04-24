//
//  PlantCollection.swift
//  laba1
//
//  Created by Ольга Ерохина on 4/4/21.
//

import Foundation
import Firebase


struct PlantsCollection: Hashable {
    let name: String
    var plants: [Plant] = []
    var identifier = UUID().uuidString

    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }

    static func ==(lhs: PlantsCollection, rhs: PlantsCollection) -> Bool {
        return lhs.identifier == rhs.identifier
    }
    
    init(name: String, plants: [Plant]) {
        self.name = name
        self.plants = plants
    }
    
    init?(snapshot: DataSnapshot, plants: [Plant]) {
        guard
            let value = snapshot.value as? [String: AnyObject],
            let name = value["name"] as? String,
            let identifier = value["identifier"] as? String else {
            return nil
        }
        
        self.name = name
        self.identifier = identifier
        self.plants = plants
    }

//    enum CodingKeys: String, CodingKey {
//        case name = "name"
//        case plants = "plants"
//        case identifier = "identifier"
//    }
    
}

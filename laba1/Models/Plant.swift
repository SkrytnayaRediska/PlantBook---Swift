//
//  Plant.swift
//  laba1
//
//  Created by Ольга Ерохина on 3/14/21.
//

import UIKit
import Firebase

final class Plant: NSObject {
    
    let ref: DatabaseReference?
    var name: String
    var lifeTime: Float
    var plantFamily: String
    var video: String
    var plantDescription: String
    var completed: Bool
    var imageUrl: String    
    
    
    
    init(name: String, lifeTime: Float, plantFamily: String, video: String, plantDescription: String, imageUrl: String, completed: Bool) {
        
        self.ref = nil
        self.name = name
        self.lifeTime = lifeTime
        self.plantFamily = plantFamily
        self.video = video
        self.plantDescription = plantDescription
        self.imageUrl = imageUrl
        self.completed = completed
        
    }
    
    init?(snapshot: DataSnapshot) {
        guard
            let value = snapshot.value as? [String: AnyObject],
            let name = value["name"] as? String,
            let lifeTime = value["lifeTime"] as? Float,
            let plantFamily = value["plantFamily"] as? String,
            let video = value["video"] as? String,
            let plantDescription = value["description"] as? String,
            var imageUrl = value["imageUrl"] as? String,
            let completed = value["completed"] as? Bool else {
            return nil
        }
        
        self.ref = snapshot.ref
        self.name = name
        self.lifeTime = lifeTime
        self.plantFamily = plantFamily
        self.video = video
        self.plantDescription = plantDescription
        self.imageUrl = imageUrl
        self.completed = completed

    }
    
//    enum CodingKeys: String, CodingKey {
//        case name = "name"
//        case lifeTime = "lifeTime"
//        case plantDescription = "description"
//        case plantFamily = "plantFamily"
//        case video = "video"
//        case imageUrl = "imageUrl"
//    }
    
    func toAnyObject() -> Any {
        return [
            "name": name,
            "lifeTime": lifeTime,
            "description": plantDescription,
            "plantFamily": plantFamily,
            "video": video,
            "imageUrl": imageUrl,
            "completed" : completed
            
        ]
    }
    
}





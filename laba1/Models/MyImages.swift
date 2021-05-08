//
//  MyImages.swift
//  laba1
//
//  Created by Ольга Ерохина on 5/6/21.
//

import Firebase

class MyImages {
    var myImages: [ImageItem] = []
    
    init?(snapshot: DataSnapshot) {
        guard
            let value = snapshot.value as? [String: AnyObject],
            let myKey = value["myKey"] as? String,
            let key = value[myKey] as? String,
            let imageUrl = value["imageUrl"] as? String else {
            return nil
        }
        
        
    }
}

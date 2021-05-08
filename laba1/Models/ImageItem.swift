//
//  ImageItem.swift
//  laba1
//
//  Created by Ольга Ерохина on 5/6/21.
//

import Firebase

class ImageItem {
    var key: DatabaseReference?
    var imageUrl: String
    
    init(key: DatabaseReference?, imageUrl: String) {
        self.key = key!
        self.imageUrl = imageUrl
    }
}

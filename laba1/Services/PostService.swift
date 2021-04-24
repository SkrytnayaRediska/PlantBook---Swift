//
//  PostService.swift
//  laba1
//
//  Created by Ольга Ерохина on 4/16/21.
//

import UIKit
import FirebaseStorage
import FirebaseDatabase

struct PlantService {
    static func create(for image: UIImage) {
        let imageRef = Storage.storage().reference().child(MyKeys.imagesFolder).child("test_image.jpg")
        StorageService.uploadImage(image, at: imageRef) { (downloadURL) in
            guard let downloadURL = downloadURL else {
                return
            }
            
            let urlString = downloadURL.absoluteURL
            print("image url: \(urlString)")
        }
    }
}



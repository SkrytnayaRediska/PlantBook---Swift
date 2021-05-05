//
//  PostService.swift
//  laba1
//
//  Created by Ольга Ерохина on 4/16/21.
//

//import UIKit
//import FirebaseStorage
//import FirebaseDatabase
//
//struct PlantService {
//
//    static func create(for image: UIImage) {
//        let imageRef = Storage.storage().reference().child(MyKeys.imagesFolder).child("test_image.jpg")
//        StorageService.uploadImage(image, at: imageRef) { (downloadURL) in
//            guard let downloadURL = downloadURL else {
//                return
//            }
//
//            let urlString = downloadURL.absoluteURL
//            print("image url: \(urlString)")
//        }
//    }
//
//    private static func create(forURLString urlString: String) {
//
//        let plant = Plant(name: "", lifeTime: 0.0, plantFamily: "", video: "", plantDescription: "", imageUrl: urlString, completed: false, mapX: 0.0, mapY: 0.0)
//
//        let dict = Plant.toAnyObject(plant)
//
//        let plantRef = Database.database().reference().child("plantsCollection/plants/0").childByAutoId()
//
//     //   plantRef.updateChildValues(dict)
//    }
//}
//


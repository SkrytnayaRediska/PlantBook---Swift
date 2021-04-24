//
//  PhotoRepository.swift
//  laba1
//
//  Created by Ольга Ерохина on 4/22/21.
//

import FirebaseStorage

class PhotoRepository {
    private static let storage = Storage.storage()
    
    static func uploadPhoto(data: Data, onLinkLoaded: @escaping (String) -> ()) {
        let storageRef = storage.reference()
        
        let photoId = UUID().uuidString
        let photosRef = storageRef
            .child(MyKeys.imagesFolder)
            .child(photoId)
        
        photosRef.putData(data, metadata: nil) { metadata, error in
            guard let _ = metadata else {
                return
            }
            
            photosRef.downloadURL { (url, error) in
                if let link = url {
                    onLinkLoaded(link.absoluteString)
                } else {
                    return
                }
            }
            
        }
    }
}

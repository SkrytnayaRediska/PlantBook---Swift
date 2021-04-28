//
//  VideoRep.swift
//  laba1
//
//  Created by Ольга Ерохина on 4/26/21.
//

import FirebaseStorage

class VideoRep {
    private static let storage = Storage.storage()
    
    static func uploadVideo(_ path: URL,
                            metadataEsc: @escaping (URL, StorageReference) ->(),
                            progressEsc: @escaping (Progress)->(),
                            completionEsc: @escaping () -> (),
                            errorEsc: @escaping (Error) -> ()) {
        
        let localFile: URL = path
        let videoName = "myVideo.mp4"
        let nameRef = storage.reference().child(videoName)
        let metadata = StorageMetadata()
        metadata.contentType = "video"
        
        let uploadTask = nameRef.putFile(from: localFile, metadata: metadata) {
            metadata, error in
            if error != nil {
                errorEsc(error!)
            } else {
                if let meta = metadata {
                    nameRef.downloadURL { (url, error) in
                        if let url = url {
                            metadataEsc(url, nameRef)
                        }
                    }
                }
            }
        }
        _ = uploadTask.observe(.progress, handler: { (snapshot) in
            if let progressSnap = snapshot.progress {
                progressEsc(progressSnap)
            }
        })
        
        _ = uploadTask.observe(.success, handler: { (snapshot) in
            if snapshot.status == .success {
                uploadTask.removeAllObservers()
                completionEsc()
            }
        })
    }
}

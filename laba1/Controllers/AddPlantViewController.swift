//
//  AddPlantViewController.swift
//  laba1
//
//  Created by Ольга Ерохина on 4/8/21.
//

import UIKit
import PhotosUI
import Firebase
import AVKit


struct MyKeys {
    static let imagesFolder = "imagesFolder"
    static let videosFolder = "videosFolder"
    static let imagesCollection = "imagesCollection"
    static let uid = "uid"
    static let imageUrl = "imageUrl"
}


class AddPlantViewController: UIViewController {
    
   //var videoPicker: VideoPicker!
    var picker = UIImagePickerController()
    var videoUrl: URL? = nil
    var uploadedVideoUrl: URL? = nil
    var pickingImage = false
    var pickingVideo = false
    
    static let identifier = String(describing: AddPlantViewController.self)
    
    var plantItem: Plant = Plant(name: "", lifeTime: 0.0, plantFamily: "", video: "", plantDescription: "", imageUrl: "", completed: false, mapX: 0.0, mapY: 0.0)
    
    var ref: DatabaseReference = Database.database().reference()
    var storageRef = Storage.storage().reference()
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var plantFamilyTextField: UITextField!
    @IBOutlet weak var lifeTimeTextField: UITextField!
    @IBOutlet weak var plantImageView: UIImageView!
    
    @IBOutlet weak var AddButton: UIButton!
    @IBOutlet weak var SaveChangesButton: UIButton!
    @IBOutlet weak var plantVideoImageView: UIImageView!
    @IBOutlet weak var addSecondaryPhotosButton: UIButton!
    
    //    @objc func onDidReceiveData(_ notification: Notification) {
//        if let data = notification.userInfo as? [String: Int] {
//            global.pathToLastItem = "plantsCollection/plants/" + String(data["lastItemIndex"] ?? 0)
//            print("HRERE")
//            print(global.pathToLastItem)
//        }
//    }
    
    
    required init?(coder: NSCoder) {
       // fatalError("init(coder:) has not been implemented")
        super.init(coder: coder)
    }
    
    init?(coder: NSCoder, plant: Plant) {
        super.init(coder: coder)
        self.plantItem = plant
        
    }
    
    @IBAction func addPlant(_ sender: Any) {
        
        addPlantToFirebase()
        _ = self.navigationController?.popViewController(animated: true)
    }
    

    
    func downloadPhoto(imageView: UIImageView, url: String) {

        let url = URL(string: url)!

        let dataTask = URLSession.shared.dataTask(with: url) { [weak self] (data, _, _) in
            if let data = data {

            DispatchQueue.main.async {
                print(data)
                imageView.image = UIImage(data: data)

            }
          }
        }
        dataTask.resume()
    }

    @IBAction func SaveChanges(_ sender: Any) {
        addPlantToFirebase()
        _ = self.navigationController?.popViewController(animated: true)
    }

  
    override func viewDidLoad() {
        super.viewDidLoad()
        print("SMOTRY SUDA - >>>>>>> \(plantItem.ref)")
        SaveChangesButton.isHidden = true
        
        if plantItem.ref != nil {
            AddButton.isHidden = true
            SaveChangesButton.isHidden = false
        }
        
        nameTextField.text = plantItem.name
        if plantItem.lifeTime != 0.0 {
        lifeTimeTextField.text = String(plantItem.lifeTime)
        }
        plantFamilyTextField.text = plantItem.plantFamily
        if plantItem.imageUrl != "" {
            downloadPhoto(imageView: plantImageView, url: plantItem.imageUrl)
        }
        
//        NotificationCenter.default.addObserver(self, selector: #selector(onDidReceiveData(_:)), name: .didReceiveData, object: nil)
//
        
        plantImageView.isUserInteractionEnabled = true
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(changeImage))
        plantImageView.addGestureRecognizer(gestureRecognizer)
        
//        plantVideoImageView.isUserInteractionEnabled = true
//        let gestureRecognizerVideo = UITapGestureRecognizer(target: self, action: #selector(changeVideo))
//        plantVideoImageView.addGestureRecognizer(gestureRecognizerVideo)
        
//        plantVideoImageView.isUserInteractionEnabled = true
//        let gestureRecognizerVideo = UITapGestureRecognizer(target: self, action: #selector(changeVideo))
//        plantVideoImageView.addGestureRecognizer(gestureRecognizerVideo)
                
        
    }
    
    @objc func changeImage() {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        configuration.selectionLimit = 1
        let controller = PHPickerViewController(configuration: configuration)
        controller.delegate = self
        present(controller, animated: true)
    }
    
//    @objc func changeVideo() {
//        self.videoPicker = VideoPicker(presentationController: self, delegate: self)
//        self.videoPicker.present(from: plantVideoImageView)
//
//       }
    
    @IBAction func showVideo(_ sender: UIButton) {
//        self.videoPicker = VideoPicker(presentationController: self, delegate: self)
//        self.videoPicker.present(from: sender)
        
        picker.delegate = self
        picker.mediaTypes = ["public.movie"]
        pickingImage = false
        pickingVideo = true
        picker.allowsEditing = false
        picker.videoExportPreset = "AVAssetExportPresetPassthrough"
        self.present(picker, animated: true, completion: nil)
    }
    //    @objc func changeVideo() {
//        var configuration = PHPickerConfiguration()
//        configuration.filter = .videos
//        configuration.selectionLimit = 1
//        let controller = PHPickerViewController(configuration: configuration)
//        controller.delegate = self
//        present(controller, animated: true)
//
//    }
    
    func uploadPhoto() {
        
        
        guard let image = plantImageView.image,
              let data = image.jpegData(compressionQuality: 0.1) else {
            print("VSTAVIT COD esly cartinka ne podoshla")
            return
        }
        PhotoRepository.uploadPhoto(data: data) { (url) in
            self.plantItem.imageUrl = url
            print(self.plantItem.imageUrl)
        }
        
//        let imageName = UUID().uuidString
//
//        let imageReference = Storage.storage().reference()
//            .child(MyKeys.imagesFolder)
//            .child(imageName)
//
//        imageReference.putData(data, metadata: nil) { (metadata, error) in
//            if let error = error {
//                print("DOPISAT COD error: \(error.localizedDescription)" )
//                return
//            }
//
//            imageReference.downloadURL { (url, error)  in
//                if let error = error {
//                    print("DOPISAT COD error: \(error.localizedDescription)" )
//                    return
//                }
//
//                let urlStr: String = (url?.absoluteString) ?? ""
//                self.plantItem.imageUrl = urlStr
//            }
//        }
    
    }
    
    
    func addPlantToFirebase() {
        
        
        plantItem.name = nameTextField.text ?? ""
        plantItem.lifeTime = (lifeTimeTextField.text as? NSString)?.floatValue ?? 0.0
        plantItem.plantFamily = plantFamilyTextField.text ?? ""
        plantItem.completed = true
        
        if plantItem.ref == nil {
        let plantItemRef = ref.child("plants").childByAutoId()
        
        plantItemRef.setValue(plantItem.toAnyObject())
        }
        else {
            plantItem.ref?.updateChildValues(plantItem.toAnyObject() as! [AnyHashable : Any])
        }
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
}


extension AddPlantViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
//        addPlantToFirebase()
        return true
    }
}


extension Notification.Name {
    static let didReceiveData = Notification.Name("didReceiveData")
    static let didCompleteTask = Notification.Name("didCompleteTask")
    static let didReciveRequest = Notification.Name("didReciveRequest")
    static let completedLengthyDownload = Notification.Name("completedLengthyDownload")
}

extension AddPlantViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        if !results.isEmpty {
            let result = results.first!
            let itemProvider = result.itemProvider
            
            if itemProvider.canLoadObject(ofClass: UIImage.self) {
                itemProvider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
                    guard let image = image as? UIImage else {
                        return
                    }
                    DispatchQueue.main.async {
                        self?.plantImageView.image = image
                        self?.uploadPhoto()
                    }
                }
            }
            
//            if itemProvider.hasItemConformingToTypeIdentifier(AVFileType.mp4.rawValue) {
//                itemProvider.loadFileRepresentation(forTypeIdentifier: UTType.movie.identifier, completionHandler: { (url, err) in
//                    if let url = url {
//                        DispatchQueue.main.sync {
//                            print("IN HERE !!!!!!!!!")
//
//                            VideoRep.uploadVideo(url) { (myUrl, ref) in
//                                print("url = \(url)") // here is the URL you can then store into your Firebase tree
//                                    print("ref = \(ref)")
//                            } progressEsc: { progress in
//                                print("progress = \(progress)")
//                            } completionEsc: {
//                                print("done")
//                            } errorEsc: { error in
//                                print("*** Error during file upload: \(error.localizedDescription)")
//                            }
//
//
//
//                        }
//                    }
//                })
//            }
        }
        picker.dismiss(animated: true, completion: nil)
    }
}

extension AddPlantViewController: UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if(pickingVideo) {
            self.videoUrl = info[.mediaURL] as? URL
            
            print(self.videoUrl?.relativeString)
            let ref = storageRef.child(videoUrl?.relativeString ?? "video")
            let metadata = StorageMetadata()
            metadata.contentType = "video/quicktime"
            
            do {
                if let videoData = NSData(contentsOf: self.videoUrl!) as Data? {
                    _ = ref.putData(videoData, metadata: metadata, completion: { metadata, error in
                        if error != nil {
                            print("FAILED UPLOAD VIDEO")
                        }
                        
                        ref.downloadURL { (URL, Error) in
                            guard let downloadUrl = URL else {
                                print("fail to get download URL")
                                return
                            }
                            
                            print("upload video!")
                            print(downloadUrl)
                            self.uploadedVideoUrl = downloadUrl
                            }
                        
                        return
                        
                    })
                }
            }
            catch {
                let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
        picker.dismiss(animated: true, completion: nil)
    }
}

extension AddPlantViewController: UINavigationControllerDelegate {
    
}


//extension AddPlantViewController: VideoPickerDelegate {
//
//    func didSelect(url: URL?) {
//        guard let url = url else {
//            return
//        }
//
//        VideoRep.uploadVideo(url) { (myUrl, ref) in
//            print("url = \(url)") // here is the URL you can then store into your Firebase tree
//                print("ref = \(ref)")
//        } progressEsc: { progress in
//            print("progress = \(progress)")
//        } completionEsc: {
//            print("done")
//        } errorEsc: { error in
//            print("*** Error during file upload: \(error.localizedDescription)")
//        }
//
//    }
//}

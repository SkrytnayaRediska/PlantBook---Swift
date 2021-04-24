//
//  AddPlantViewController.swift
//  laba1
//
//  Created by Ольга Ерохина on 4/8/21.
//

import UIKit
import PhotosUI
import Firebase


struct MyKeys {
    static let imagesFolder = "imagesFolder"
    static let imagesCollection = "imagesCollection"
    static let uid = "uid"
    static let imageUrl = "imageUrl"
}


class AddPlantViewController: UIViewController {
    
    var plantItem: Plant = Plant(name: "", lifeTime: 0.0, plantFamily: "", video: "", plantDescription: "", imageUrl: "", completed: false)
    
    var ref: DatabaseReference = Database.database().reference()
    var storageRef = Storage.storage().reference()
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var plantFamilyTextField: UITextField!
    @IBOutlet weak var lifeTimeTextField: UITextField!
    @IBOutlet weak var plantImageView: UIImageView!
    
//    @objc func onDidReceiveData(_ notification: Notification) {
//        if let data = notification.userInfo as? [String: Int] {
//            global.pathToLastItem = "plantsCollection/plants/" + String(data["lastItemIndex"] ?? 0)
//            print("HRERE")
//            print(global.pathToLastItem)
//        }
//    }
    
    @IBAction func addPlant(_ sender: Any) {
        
        addPlantToFirebase()
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        NotificationCenter.default.addObserver(self, selector: #selector(onDidReceiveData(_:)), name: .didReceiveData, object: nil)
//
        plantImageView.isUserInteractionEnabled = true
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(changeImage))
        plantImageView.addGestureRecognizer(gestureRecognizer)
        
    }
    
    @objc func changeImage() {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        configuration.selectionLimit = 1
        let controller = PHPickerViewController(configuration: configuration)
        controller.delegate = self
        present(controller, animated: true)
    }
    
    
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
        
        let plantItemRef = ref.child("plants").childByAutoId()
        
        plantItemRef.setValue(plantItem.toAnyObject())
        
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
        }
        picker.dismiss(animated: true, completion: nil)
    }
}

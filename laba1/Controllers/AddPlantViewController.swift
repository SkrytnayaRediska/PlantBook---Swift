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
    var pickingMainPhoto = false
    var pickingVideo = false
    private var isDarkMode: Bool = false
    
    static let identifier = String(describing: AddPlantViewController.self)
    
    var plantItem: Plant = Plant(name: "", lifeTime: 0.0, plantFamily: "", video: "", plantDescription: "", imageUrl: [""], completed: false, mapX: 0.0, mapY: 0.0)
    
    var ref: DatabaseReference = Database.database().reference()
    var storageRef = Storage.storage().reference()
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var plantFamilyTextField: UITextField!
    @IBOutlet weak var lifeTimeTextField: UITextField!
    @IBOutlet weak var plantImageView: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var plantFamilyLabel: UILabel!
    @IBOutlet weak var lifeTimeLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var AddButton: UIButton!
    @IBOutlet weak var SaveChangesButton: UIButton!
    @IBOutlet weak var plantVideoImageView: UIImageView!
    @IBOutlet weak var videoButton: UIButton!
    
    @IBOutlet weak var addSecondaryPhotosButton: UIButton!
    
    @IBOutlet weak var plantDescription: UITextView!
    
    
    required init?(coder: NSCoder) {
       // fatalError("init(coder:) has not been implemented")
        isDarkMode = ThemeManager.isDarkMode()
        super.init(coder: coder)
    }
    
    init?(coder: NSCoder, plant: Plant, isDarkMode: Bool) {
        self.isDarkMode = isDarkMode
        super.init(coder: coder)
        self.plantItem = plant
    }
    
    @IBAction func addPlant(_ sender: Any) {
        if fieldCheck() {
        addPlantToFirebase()
        _ = self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func addSecondaryPhotos(_ sender: Any) {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        configuration.selectionLimit = 5
        let controller =  PHPickerViewController(configuration: configuration)
        controller.delegate = self
        present(controller, animated: true)
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
    
    func fieldCheck() -> Bool {
        
        var title = ""
        var completed = true
        var showAllert = false
        
        if nameTextField.text == "" {
            title = "name field is empty"
            completed = false
            showAllert = true
        }
        
        if plantFamilyTextField.text == "" {
            title = "Family field is empty"
            completed = false
            showAllert = true
        }

        if lifeTimeTextField.text == "" {
            title = "life time field is empty"
            completed = false
            showAllert = true
        }
        
        if plantDescription.text == "" {
            title = "Description field is empty"
            completed = false
            showAllert = true
        }
        if plantItem.video == "" {
        if uploadedVideoUrl == nil {
            title = "Video has not been selected or upload didn't finish"
            completed = false
            showAllert = true
        }
        }
        
        if showAllert {
            let alert = UIAlertController(title: title, message: "Plese fill out the fields", preferredStyle: .alert)

            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true)
        }
    
        
        return completed
    }

    @IBAction func SaveChanges(_ sender: Any) {
        if fieldCheck() {
        addPlantToFirebase()
        _ = self.navigationController?.popViewController(animated: true)
        }
            
    }

  
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        ThemeManager.addDarkModeObserver(to: self, selector: #selector(enableDarkMode))
        
        nameTextField.delegate = self
        lifeTimeTextField.delegate = self
        plantFamilyTextField.delegate = self
        
        
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
        if plantItem.imageUrl[0] != "" {
            downloadPhoto(imageView: plantImageView, url: plantItem.imageUrl[0])
        }
        if plantItem.plantDescription != "" {
            plantDescription.text = plantItem.plantDescription
        }
        

        
        plantImageView.isUserInteractionEnabled = true
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(changeImage))
        plantImageView.addGestureRecognizer(gestureRecognizer)
        
        if isDarkMode { enableDarkMode() }
          
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        lifeTimeTextField.resignFirstResponder()
        plantDescription.resignFirstResponder()
        
    }
    
    @objc func enableDarkMode() {
        let currentTheme = ThemeManager.currentTheme
        
        view.backgroundColor = currentTheme.backgroundColor
        nameLabel.textColor = currentTheme.textColor
        plantFamilyLabel.textColor = currentTheme.textColor
        lifeTimeLabel.textColor = currentTheme.textColor
        descriptionLabel.textColor = currentTheme.textColor
        
        AddButton.setTitleColor(currentTheme.textColor, for: .normal)
        SaveChangesButton.setTitleColor(currentTheme.textColor, for: .normal)
        addSecondaryPhotosButton.setTitleColor(currentTheme.textColor, for: .normal)
        videoButton.setTitleColor(currentTheme.textColor, for: .normal)
        
        nameTextField.backgroundColor = currentTheme.backgroundColorForFields
        
        
    }
    
    @objc func changeImage() {
        pickingMainPhoto = true
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        configuration.selectionLimit = 1
        let controller = PHPickerViewController(configuration: configuration)
        controller.delegate = self
        present(controller, animated: true)
    }
    

    
    @IBAction func showVideo(_ sender: UIButton) {
    
        picker.delegate = self
        picker.mediaTypes = ["public.movie"]
        pickingImage = false
        pickingVideo = true
        picker.allowsEditing = false
        picker.videoExportPreset = "AVAssetExportPresetPassthrough"
        self.present(picker, animated: true, completion: nil)
    }
 
    func uploadPhoto() {
        
        guard let image = plantImageView.image,
              let data = image.jpegData(compressionQuality: 0.1) else {
            print("VSTAVIT COD esly cartinka ne podoshla")
            return
        }
        PhotoRepository.uploadPhoto(data: data) { (url) in
            self.plantItem.imageUrl[0] = url
            print(self.plantItem.imageUrl)
        }
    }
    
    func uploadPhoto(image: UIImage) {
        guard let data = image.jpegData(compressionQuality: 0.1) else {
            print("Cant convert image \(image) to Data format")
            return
        }
        PhotoRepository.uploadPhoto(data: data) { (url) in
            self.plantItem.imageUrl.append(url)
        }
    }
    
    
    func addPlantToFirebase() {
        
        plantItem.name = nameTextField.text ?? ""
        plantItem.lifeTime = (lifeTimeTextField.text as? NSString)?.floatValue ?? 0.0
        plantItem.plantFamily = plantFamilyTextField.text ?? ""
        plantItem.plantDescription = plantDescription.text
        if plantItem.video == "" {
            plantItem.video = uploadedVideoUrl!.absoluteString
        }
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
        
        if pickingMainPhoto {
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
        } else {
            if !results.isEmpty {
                for result in results {
                    let itemProvider = result.itemProvider
                    
                    if itemProvider.canLoadObject(ofClass: UIImage.self) {
                        itemProvider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
                            guard let image = image as? UIImage else {
                                return
                            }
                            DispatchQueue.main.async {
                                self?.uploadPhoto(image: image)
                            }
                        }
                    }
                }
            }
        }
        
        pickingMainPhoto = false
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


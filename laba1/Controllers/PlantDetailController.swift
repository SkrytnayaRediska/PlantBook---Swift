//
//  PlantDetailController.swift
//  laba1
//
//  Created by Ольга Ерохина on 4/7/21.
//

import UIKit
import AVKit
import FirebaseAuth

final class PlantDetailViewController: UIViewController {

    
    
    
    static let identifier = String(describing: PlantDetailViewController.self)
    
    private let plant: Plant
    
    private var isDarkMode: Bool
    
    private var changedTheme: UIColor?
    
    private var fontSize: CGFloat?
    
    



    
    
    @IBOutlet weak var lifeTimeUILabel: UILabel!
    
    @IBOutlet weak var plantCoverImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var plantFamilyLabel: UILabel!
    @IBOutlet weak var lifeTimeLabel: UILabel!
    @IBOutlet weak var descriptionTextVIew: UITextView!
    
    @IBOutlet weak var videosLabelButton: UIButton!
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init?(coder: NSCoder, plant: Plant, isDarkMode: Bool, currentTheme: UIColor?,
          fontSize: CGFloat?) {
        
        self.plant = plant
        self.isDarkMode = isDarkMode
        self.changedTheme = currentTheme
        self.fontSize = fontSize
        super.init(coder: coder)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(editTaped))
//        (barButtonSystemItem: .edit, target: self, action: #selector(editTaped))
        plantCoverImageView.isUserInteractionEnabled = true
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(showPhotoCollection))
        plantCoverImageView.addGestureRecognizer(gestureRecognizer)
        
        if isDarkMode { enableDarkMode() }
        if changedTheme != nil { enableDarkMode() }
        if fontSize != nil { changeUIFont(fontSize: fontSize!)}
    }
    
    
    
    @objc func showPhotoCollection() {
        
        if let plantDetailController = storyboard?.instantiateViewController(identifier: PhotosCollectionViewController.identifier, creator: { coder in
            return PhotosCollectionViewController(coder: coder, plant: self.plant, isEditMode: false)
        }) {
       show(plantDetailController, sender: nil)
     }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidLoad()
        setupView()
        changeLabels()
    }
    
    @objc func editTaped() {
       
        if Auth.auth().currentUser != nil {
            if let plantDetailController = storyboard?.instantiateViewController(identifier: AddPlantViewController.identifier, creator: { coder in
                return AddPlantViewController(coder: coder, plant: self.plant, isDarkMode: self.isDarkMode, currentTheme: self.changedTheme, fontSize: self.fontSize)
            }) {
           show(plantDetailController, sender: nil)
         }

        } else {
            let alert = UIAlertController(title: "Edit mode is LOCKED".localized(), message: "SignUpRestriction".localized(), preferredStyle: .alert)

            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true)
        }
    }
    
    @IBAction func ShowVideo(_ sender: Any) {
        print("hellio")
        if plant.video == "" {
            let alert = UIAlertController(title: "There is no video".localized(), message: "Please add video".localized(), preferredStyle: .alert)

            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                print("YO")
            }))
            self.present(alert, animated: true)
        } else {
            let video = AVPlayer(url: URL(string: plant.video)!)
            let videoPlayer =  AVPlayerViewController()
            
            videoPlayer.player = video
            
            self.present(videoPlayer, animated: true) {
                video.play()
        }
        }
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
    
    @objc func enableDarkMode() {
        let currentTheme = ThemeManager.setCurrentTheme(changedTheme)
        nameLabel.textColor = currentTheme.textColor
        view.backgroundColor = currentTheme.backgroundColor
        plantFamilyLabel.textColor = currentTheme.textColor.withAlphaComponent(0.5)
        lifeTimeUILabel.textColor = currentTheme.textColor
        descriptionTextVIew.textColor = currentTheme.textColor
        videosLabelButton.setTitleColor(currentTheme.textColor, for: .normal)
        
    }
    
    @objc func onChangedColor(_ notification: Notification) {
        if let data = notification.userInfo as? [String: UIColor] {
            changedTheme = data["color"]
        }
    }
    
    @objc func onChangedFont(_ notification: Notification) {
        if let data = notification.userInfo as? [String: CGFloat] {
            fontSize = data["fontSize"]
            // IF there is any aditional items
            changeUIFont(fontSize: fontSize!)
            
        }
    }
    @objc func changeLabels() {
        lifeTimeUILabel.text = "Life time is".localized()
        
        videosLabelButton.setTitle("Videos".localized(), for: .normal)
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit".localized(),
                                style: .plain, target: self, action: #selector(editTaped))
        
        
    }
    
    func changeUIFont(fontSize: CGFloat) {
        nameLabel.font = nameLabel.font.withSize(fontSize)
        plantFamilyLabel.font = nameLabel.font.withSize(fontSize)
        lifeTimeLabel.font = lifeTimeLabel.font.withSize(fontSize)
        lifeTimeUILabel.font = lifeTimeUILabel.font.withSize(fontSize)
        videosLabelButton.titleLabel?.font = videosLabelButton.titleLabel?.font.withSize(fontSize)
        descriptionTextVIew.font = descriptionTextVIew.font?.withSize(fontSize)
        
    }
    
    private func setupView() {
        ThemeManager.addDarkModeObserver(to: self, selector: #selector(enableDarkMode))
        NotificationCenter.default.addObserver(self, selector: #selector(onChangedColor(_:)),
                                               name: .changedColor, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onChangedFont(_:)),
                                               name: .fontChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(changeLabels),
                                               name: .languageChanged, object: nil)
        
        self.title = plant.name
        downloadPhoto(imageView: plantCoverImageView, url: plant.imageUrl[0])
        nameLabel.text = plant.name
        plantFamilyLabel.text = plant.plantFamily
        lifeTimeLabel.text = String(plant.lifeTime)
        descriptionTextVIew.isEditable = false
        descriptionTextVIew.text = plant.plantDescription
        
    }
}



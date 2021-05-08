//
//  PlantDetailController.swift
//  laba1
//
//  Created by Ольга Ерохина on 4/7/21.
//

import UIKit
import AVKit

final class PlantDetailViewController: UIViewController {

    
    
    
    static let identifier = String(describing: PlantDetailViewController.self)
    
    private let plant: Plant
    
    private var isDarkMode: Bool



    
    
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
    
    init?(coder: NSCoder, plant: Plant, isDarkMode: Bool) {
        
        self.plant = plant
        self.isDarkMode = isDarkMode
        super.init(coder: coder)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editTaped))
        
        plantCoverImageView.isUserInteractionEnabled = true
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(showPhotoCollection))
        plantCoverImageView.addGestureRecognizer(gestureRecognizer)
        
        if isDarkMode { enableDarkMode() }
    
    }
    
    
    
    @objc func showPhotoCollection() {
        
        if let plantDetailController = storyboard?.instantiateViewController(identifier: PhotosCollectionViewController.identifier, creator: { coder in
            return PhotosCollectionViewController(coder: coder, plant: self.plant)
        }) {
       show(plantDetailController, sender: nil)
     }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidLoad()
        setupView()
    }
    
    @objc func editTaped() {
        if let plantDetailController = storyboard?.instantiateViewController(identifier: AddPlantViewController.identifier, creator: { coder in
            return AddPlantViewController(coder: coder, plant: self.plant, isDarkMode: self.isDarkMode)
        }) {
       show(plantDetailController, sender: nil)
     }
    }
    
    @IBAction func ShowVideo(_ sender: Any) {
        print("hellio")
    
        let video = AVPlayer(url: URL(string: plant.video)!)
        let videoPlayer =  AVPlayerViewController()
        
        videoPlayer.player = video
        
        self.present(videoPlayer, animated: true) {
            video.play()
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
        let currentTheme = ThemeManager.currentTheme
        nameLabel.textColor = currentTheme.textColor
        view.backgroundColor = currentTheme.backgroundColor
        plantFamilyLabel.textColor = currentTheme.textColor.withAlphaComponent(0.5)
        lifeTimeUILabel.textColor = currentTheme.textColor
        descriptionTextVIew.textColor = currentTheme.textColor
        videosLabelButton.setTitleColor(currentTheme.textColor, for: .normal)
        
    }
    
    private func setupView() {
        ThemeManager.addDarkModeObserver(to: self, selector: #selector(enableDarkMode))
        
        self.title = plant.name
        downloadPhoto(imageView: plantCoverImageView, url: plant.imageUrl[0])
        nameLabel.text = plant.name
        plantFamilyLabel.text = plant.plantFamily
        lifeTimeLabel.text = String(plant.lifeTime)
        descriptionTextVIew.isEditable = false
        descriptionTextVIew.text = plant.plantDescription
        
    }
}



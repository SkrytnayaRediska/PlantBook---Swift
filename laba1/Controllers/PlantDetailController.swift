//
//  PlantDetailController.swift
//  laba1
//
//  Created by Ольга Ерохина on 4/7/21.
//

import UIKit

final class PlantDetailViewController: UIViewController {

    
    
    
    static let identifier = String(describing: PlantDetailViewController.self)
    
    private let plant: Plant
    
    
    
    @IBOutlet weak var plantCoverImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var plantFamilyLabel: UILabel!

    @IBOutlet weak var videoLabel: UILabel!
    
    @IBOutlet weak var videoTextView: UITextView!
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init?(coder: NSCoder, plant: Plant) {
        self.plant = plant
        super.init(coder: coder)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
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
    
    
    private func setupView() {
        self.title = plant.name
        downloadPhoto(imageView: plantCoverImageView, url: plant.imageUrl)// MARK: - ЗАГЛУШКА (ПОФИКИСИТЬ) -
        nameLabel.text = plant.name
        plantFamilyLabel.text = plant.plantFamily
        videoLabel.text = plant.video
        videoTextView.isEditable = false;
        videoTextView.text = plant.video
    }
}



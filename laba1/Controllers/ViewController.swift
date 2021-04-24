//
//  ViewController.swift
//  laba1
//
//  Created by Ольга Ерохина on 3/14/21.
//

import UIKit
import Photos

import Firebase

final class ViewController: UIViewController, UITextFieldDelegate{

    
    var ref: DatabaseReference!
    var data: [DataSnapshot] = []
    var items: [Plant] = []
    fileprivate var _refHandle: DatabaseHandle!
    
    var storageRef: StorageReference!
    var remoteConfig: RemoteConfig!
    
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    
     var dataSource: UICollectionViewDiffableDataSource<PlantsCollection, Plant>!
    
    
    override func viewDidLoad() {
      super.viewDidLoad()
      setupView()
     }
    
    
    private func setupView() {
      self.title = "Library"
        collectionView.delegate = self
        
        collectionView.collectionViewLayout = configureCollectionViewLayout()
    
        configureDatabase()
        configureDataSource()

    }
    
    
    
    // MARK: Add Item
    
    @IBAction func addButtonDidTouch(_ sender: AnyObject) {
        
    }
}


 // MARK: - Collection View -


extension ViewController {
    func configureCollectionViewLayout() -> UICollectionViewCompositionalLayout {
        
            
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.33), heightDimension: .fractionalHeight(1.0))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
            
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(0.2))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
            
            let section = NSCollectionLayoutSection(group: group)
            
            
            return UICollectionViewCompositionalLayout(section: section)
    }
    
    func downloadPhoto(cell: PlantCell, url: String) {

        let url = URL(string: url)!

        let dataTask = URLSession.shared.dataTask(with: url) { [weak self] (data, _, _) in
            if let data = data {

            DispatchQueue.main.async {
                print(data)
                cell.plantImage.image = UIImage(data: data)

            }
          }
        }
        dataTask.resume()
    }
    
    func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<PlantsCollection, Plant>(collectionView: collectionView) {
            (collectionView, indexPath, plant) -> UICollectionViewCell? in
            
            guard let cell =
                    collectionView.dequeueReusableCell(withReuseIdentifier: PlantCell.reuseIdentifier, for: indexPath) as? PlantCell else {
                fatalError("Cannot create new cell")
            }
            
            
            cell.titleLabel.text = plant.name
            self.downloadPhoto(cell: cell, url: plant.imageUrl)
            
            
          //  cell.plantImage.image = plant
            

            return cell
        }
       
    }
    
    func configureSnapshot(myPlants : PlantsCollection) {
        var currentSnapshot = NSDiffableDataSourceSnapshot<PlantsCollection, Plant>()
        
        

        currentSnapshot.appendSections([myPlants])
        currentSnapshot.appendItems(myPlants.plants)
        self.dataSource.apply(currentSnapshot, animatingDifferences: false)



    }

}




// MARK: "Configure Database"

extension ViewController {
    
    func configureDatabase() {
        ref = Database.database().reference()
        // Listen for new messages in the Firebase database\
        
        
        ref.child("plants").observe(.value) { snapshot in
            print(" HERERERERE \(snapshot)")
            var newItems: [Plant] = []
            for child in snapshot.children {
                if let snapshot = child as? DataSnapshot,
                   let plantItem = Plant(snapshot: snapshot) {
                    print("snapshot HERE!!! \(snapshot)")
                    print("in HERE in in \(plantItem.lifeTime)")
                    if(plantItem.imageUrl == "") {
                        return
                    }
                    if(plantItem.completed && plantItem.imageUrl != "") {
                    newItems.append(plantItem)
                    }
                }
            }
            self.items = newItems
            
            let collection = PlantsCollection(name: "plantsCollection", plants: self.items)
            
            self.configureSnapshot(myPlants: collection)
            
//            let jsonData = try! JSONSerialization.data(withJSONObject: snapshot.value!, options: .prettyPrinted)
//            let myRealData = try! JSONDecoder().decode(PlantsCollection.self, from: jsonData)
//
//            let lastItemIndex = ["lastItemIndex" : myRealData.plants.count]
//            NotificationCenter.default.post(name: .didReceiveData, object: self, userInfo: lastItemIndex)
//
//            self.configureSnapshot(myPlants: myRealData)
            
        }
    }
}

// MARK: - UICollectionViewDelegate -

extension ViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let plant = dataSource.itemIdentifier(for: indexPath),
           let plantDetailController = storyboard?.instantiateViewController(identifier: PlantDetailViewController.identifier, creator: { coder in
            return PlantDetailViewController(coder: coder, plant: plant)
           }) {
          show(plantDetailController, sender: nil)
        }
    }
}



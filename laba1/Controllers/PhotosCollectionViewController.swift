//
//  PhotosCollectionViewController.swift
//  laba1
//
//  Created by Ольга Ерохина on 4/29/21.
//

import UIKit

class PhotosCollectionViewController: UIViewController {
    
    static let identifier = String(describing: PhotosCollectionViewController.self)
    private let plant: Plant
    private let isEditMode: Bool

    
    @IBOutlet weak var photosCollectionView: UICollectionView!
    
    var dataSource: UICollectionViewDiffableDataSource<[String], String>!
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init?(coder: NSCoder, plant: Plant, isEditMode: Bool) {

        self.plant = plant
        self.isEditMode = isEditMode
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if isEditMode {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteTapped))
        }
        photosCollectionView.collectionViewLayout = configureCollectionViewLayout()
        configureDataSource()
        configureSnapshot(plant: plant)
    }

    @objc func deleteTapped() {
        if plant.imageUrl.count == 1 {
            let alert = UIAlertController(title: "Can not delete last photo".localized(), message: "Item must have at least one photo".localized(), preferredStyle: .alert)

            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true)
        } else {
        var visibleCell = photosCollectionView.visibleCells[0]
        var indexPath = photosCollectionView.indexPath(for: visibleCell)!
        var currentPhoto = dataSource.itemIdentifier(for: indexPath)!
        deletePhoto(currentPhoto)
        configureSnapshot(plant: plant)
        photosCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        }
    }
    
    func deletePhoto(_ photo: String) {
        var index = plant.imageUrl.firstIndex(of: photo)!
        plant.imageUrl.remove(at: index)

    }

}


extension PhotosCollectionViewController {
    func configureCollectionViewLayout() -> UICollectionViewCompositionalLayout {
    
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
            
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
            
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .groupPaging
        
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    func downloadPhoto(cell: ImageCell, url: String) {

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
        dataSource = UICollectionViewDiffableDataSource<[String], String>(collectionView: photosCollectionView) {
            (collectionView, indexPath, plant) -> UICollectionViewCell? in
            
            guard let cell =
                    collectionView.dequeueReusableCell(withReuseIdentifier: ImageCell.reuseIdentifier, for: indexPath) as? ImageCell else {
                fatalError("Cannot create new cell")
            }
            
            
            self.downloadPhoto(cell: cell, url: plant)
            
            
          //  cell.plantImage.image = plant
            

            return cell
        }
    }
    
    func configureSnapshot(plant : Plant) {
        var currentSnapshot = NSDiffableDataSourceSnapshot<[String], String>()
        
        
        currentSnapshot.appendSections([plant.imageUrl])
        currentSnapshot.appendItems(plant.imageUrl)
        self.dataSource.apply(currentSnapshot, animatingDifferences: false)

    }


}

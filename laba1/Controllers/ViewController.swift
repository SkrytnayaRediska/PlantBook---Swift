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
    private var isDarkMode = false
    private var changedTheme: UIColor?
    private var fontSize: CGFloat?
    private var isRussianLanguage = false
    
    var storageRef: StorageReference!
//    var remoteConfig: RemoteConfig!
    
    
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var navItem: UINavigationItem!
    
    
     var dataSource: UICollectionViewDiffableDataSource<PlantsCollection, Plant>!
    
    override func viewWillAppear(_ animated: Bool) {
        self.parent?.navigationController?.isNavigationBarHidden = true
        enableDarkMode()
    }
    
    override func viewDidLoad() {
      super.viewDidLoad()

      setupView()
        
        NotificationCenter.default.addObserver(self, selector: #selector(onDidReceiveRequest(_:)), name: .didReciveRequest, object: nil)
         
        NotificationCenter.default.addObserver(self, selector: #selector(onDidReceiveColorRequest(_:)), name: .requestForColor, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(onChangedColor(_:)), name: .changedColor, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(onChangedFont(_:)), name: .fontChanged, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(onDidReceiveFontSizeRequest(_:)), name: .requestForFontSize, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(changeLabels), name: .languageChanged, object: nil)
        
        if ThemeManager.isDarkMode() {
            enableDarkMode()
        }
        
        
     }
    
    @objc func onDidReceiveFontSizeRequest(_ notification: Notification) {
       
        let fontSize = ["fontMain" : self.fontSize]
        NotificationCenter.default.post(name: .didReceiveFontSize, object: self, userInfo: fontSize)
                
    }
    
    @objc func onChangedFont(_ notification: Notification) {
        if let data = notification.userInfo as? [String: CGFloat] {
            fontSize = data["fontSize"]
            // IF there is any aditional items
            print(fontSize)
            
        }
    }
    
    @objc func onChangedColor(_ notification: Notification) {
        if let data = notification.userInfo as? [String: UIColor] {
            changedTheme = data["color"]
        }
    }
    
    @objc func onDidReceiveRequest(_ notification: Notification) {
       
        let allItems = ["allItems" : items]
        NotificationCenter.default.post(name: .didReceiveData, object: self, userInfo: allItems)
                
    }

    @objc func onDidReceiveColorRequest(_ notification: Notification) {
        let color = ["colorMain" : changedTheme]
        NotificationCenter.default.post(name: .didReceiveColor, object: self, userInfo: color)
    }
    
    @objc func changeLabels() {
        navItem.title = "Library".localized()
        
    }
    
    private func setupView() {
        ThemeManager.addDarkModeObserver(to: self, selector: #selector(enableDarkMode))
        
      self.title = "Library"
        collectionView.delegate = self
        
        collectionView.collectionViewLayout = configureCollectionViewLayout()
    
        configureDatabase()
        configureDataSource()
        

    }
    
    @objc func enableDarkMode() {
        isDarkMode = ThemeManager.isDarkMode()
        let currentTheme = ThemeManager.setCurrentTheme(changedTheme)
        collectionView.backgroundColor = currentTheme.backgroundColor
        navigationController?.navigationBar.barTintColor = currentTheme.backgroundColorForNavigationBar
        
        if fontSize == nil { fontSize = 17.0}
        let attributes = [
          NSAttributedString.Key.font: UIFont.systemFont(ofSize: fontSize!),
            NSAttributedString.Key.foregroundColor: currentTheme.textColor
        ]
        
        navigationController?.navigationBar.titleTextAttributes = attributes
        tabBarController?.tabBar.barTintColor = currentTheme.backgroundColorForNavigationBar
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? AddPlantViewController {
            vc.changedTheme = self.changedTheme
            vc.fontSize = self.fontSize
        }
    }

    @IBAction func addButtonTapped(_ sender: Any) {
        if Auth.auth().currentUser != nil {
            
            self.performSegue(withIdentifier: Constants.Segues.AddPlant, sender: nil)
        } else {
            let alert = UIAlertController(title: "Edit mode is LOCKED".localized(), message: "SignUpRestriction".localized(), preferredStyle: .alert)

            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true)
        }
    }
}
    
    // MARK: Add Item
    


 // MARK: - Collection View -


extension ViewController {
    func configureCollectionViewLayout() -> UICollectionViewCompositionalLayout {
        
            
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.33), heightDimension: .fractionalHeight(1.0))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
            
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(0.33))
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
            
            
            cell.titleLabel.backgroundColor = UIColor.systemGray.withAlphaComponent(0.8)
            cell.familyLabel.backgroundColor = UIColor.systemGray.withAlphaComponent(0.8)
            cell.ageLabel.backgroundColor = UIColor.systemGray.withAlphaComponent(0.8)
            
            cell.titleLabel.text = plant.name
            cell.familyLabel.text = plant.plantFamily
            cell.ageLabel.text = String(plant.lifeTime)
            self.downloadPhoto(cell: cell, url: plant.imageUrl[0])
            
            
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
                    snapshot.value
                    print("snapshot HERE!!! \(snapshot)")
                    print("in HERE in in \(plantItem.lifeTime)")
                    if(plantItem.imageUrl[0] == "") {
                        return
                    }
                    if(plantItem.completed && plantItem.imageUrl[0] != "") {
                    newItems.append(plantItem)
                    }
                }
            }
            self.items = newItems
            
            let collection = PlantsCollection(name: "plantsCollection", plants: self.items)
            
//            let allItems = ["allItems" : self.items]
//            NotificationCenter.default.post(name: .didReceiveData, object: self, userInfo: allItems)
            
            self.configureSnapshot(myPlants: collection)
            
//            let jsonData = try! JSONSerialization.data(withJSONObject: snapshot.value!, options: .prettyPrinted)
//            let myRealData = try! JSONDecoder().decode(PlantsCollection.self, from: jsonData)
//
//            let lastItemIndex = ["lastItemIndex" : myRealData.plants.count]
//            let allItems = ["allItems" : newItems]
//            NotificationCenter.default.post(name: .didReceiveData, object: self, userInfo: allItems)
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
            return PlantDetailViewController(coder: coder, plant: plant, isDarkMode: self.isDarkMode, currentTheme: self.changedTheme, fontSize: self.fontSize)
           }) {
          show(plantDetailController, sender: nil)
        }
    }
}
    

extension Bundle {
    private static var bundle: Bundle!
    
    public static func localizedBundle() -> Bundle! {
        if bundle == nil {
            let appLang = UserDefaults.standard.string(forKey: "app_lang") ?? "ru"
            let path = Bundle.main.path(forResource: appLang, ofType: "lproj")
            bundle = Bundle(path: path!)
        }
        
        return bundle
    }
    
    public static func setLanguage(lang: String) {
        UserDefaults.standard.set(lang, forKey: "app_lang")
        let path = Bundle.main.path(forResource: lang, ofType: "lproj")
        bundle = Bundle(path: path!)
    }
}

extension String {
    func localized() -> String {
        return NSLocalizedString(self, tableName: nil, bundle: Bundle.localizedBundle(), value: "", comment: "")
    }
    
    func localizeWithFormat(arguments: CVarArg...) -> String {
        return String(format: self.localized(), arguments: arguments)
    }
}


extension Notification.Name {
    static let languageChanged = Notification.Name("languageChanged")
}

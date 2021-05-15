//
//  MapViewController.swift
//  laba1
//
//  Created by Ольга Ерохина on 4/27/21.
//

import UIKit
import MapKit
import CoreLocation


class MapViewController: UIViewController {
    
    var plants: [Plant] = []
    let defaultRegionCordinage: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 53.893009, longitude: 27.567444)
    
    private var changedTheme: UIColor?
    private var fontSize: CGFloat?
    private let locationManager = CLLocationManager()
    @IBOutlet weak var mapNavItem: UINavigationItem!
    
    @IBOutlet weak var mapView: MKMapView!
    


    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.post(name: .didReciveRequest, object: self)
        NotificationCenter.default.post(name: .requestForColor, object: self)
        NotificationCenter.default.post(name: .requestForFontSize, object: nil)
        enableDarkMode()
        changeLabels()
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        let myAnnotation = view.annotation as? MKPointAnnotation
        print(myAnnotation)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        mapView.register(
          PlantMarkerView.self,
          forAnnotationViewWithReuseIdentifier:
            MKMapViewDefaultAnnotationViewReuseIdentifier)

        
        setUpView()
        
        NotificationCenter.default.addObserver(self, selector: #selector(onDidReceiveData(_:)), name: .didReceiveData, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onDidReceiveColor(_:)), name: .didReceiveColor, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onDidReceiveFontSize(_:)), name: .didReceiveFontSize, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onChangedFont(_:)), name: .fontChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(changeLabels), name: .languageChanged, object: nil)
        
        
        
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        
        if ThemeManager.isDarkMode() {
            enableDarkMode()
        }
        if changedTheme != nil {
            enableDarkMode()
        }
        
        if fontSize != nil {
            // MAKE something
        }

    
    }
    
    func setUpView() {
        ThemeManager.addDarkModeObserver(to: self, selector: #selector(enableDarkMode))
        NotificationCenter.default.addObserver(self, selector: #selector(onChangedColor(_:)), name: .changedColor, object: nil)
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
//            print("YO")
        }
    }
    
    @objc func onDidReceiveColor(_ notification: Notification) {
        if let data = notification.userInfo as? [String: UIColor] {
            changedTheme = data["colorMain"]
            print("YO")
        }
    }
    
    @objc func onDidReceiveFontSize(_ notification: Notification) {
        if let data = notification.userInfo as? [String: CGFloat] {
            fontSize = data["fontMain"]
            print("yo")
        }
    }
    
    @objc func changeLabels() {
        mapNavItem.title = "Map".localized()
        
    }
    
    
    @objc func enableDarkMode() {
        let currentTheme = ThemeManager.currentTheme
        
        navigationController?.navigationBar.barTintColor = currentTheme.backgroundColorForNavigationBar
        
        if fontSize == nil { fontSize = 17.0 }
        
        let attributes = [
          NSAttributedString.Key.font: UIFont.systemFont(ofSize: fontSize!),
            NSAttributedString.Key.foregroundColor: currentTheme.textColor
        ]
        
        navigationController?.navigationBar.titleTextAttributes = attributes
    }
    
    @objc func onDidReceiveData(_ notification: Notification) {
        
        

        if let data = notification.userInfo as? [String: [Plant]] {
            plants = data["allItems"]!
            for plant in plants {
                print("MY PLANT \(plant)")
                
                let annotation = PlantAnnotation(title: plant.name, subtitle: plant.plantFamily, discipline: plant.plantDescription, coordinate: CLLocationCoordinate2DMake(plant.mapX, plant.mapY), plantItem: plant
                )
                
                mapView.addAnnotation(annotation)
            
                
            }
        }
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        let allAnotations = self.mapView.annotations
        mapView.removeAnnotations(allAnotations)
    }
    
    deinit {
         print("Remove NotificationCenter Deinit")
        NotificationCenter.default.removeObserver(self)
     }
    
        
}



extension MapViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        print("DID REVIVE YOUR LOCATION \(locations)")
        if let location = locations.first {
            let latitude = location.coordinate.latitude
            let longitude = location.coordinate.longitude
            
            let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: latitude, longitude: longitude), latitudinalMeters: 500, longitudinalMeters: 500)
            
            mapView.setRegion(region, animated: true)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error geting location \(error.localizedDescription)")
        
        let region = MKCoordinateRegion(center: defaultRegionCordinage, latitudinalMeters: 1000, longitudinalMeters: 1000)
        mapView.setRegion(region, animated: false)
    }
    

}


extension MapViewController: MKMapViewDelegate {
    func mapView(
      _ mapView: MKMapView,
      annotationView view: MKAnnotationView,
      calloutAccessoryControlTapped control: UIControl
    ) {
      guard let plantAnnotation = view.annotation as? PlantAnnotation else {
        return
      }

           if let plantDetailController = storyboard?.instantiateViewController(identifier: PlantDetailViewController.identifier, creator: { coder in
            return PlantDetailViewController(coder: coder, plant: plantAnnotation.plantItem!, isDarkMode: ThemeManager.isDarkMode(), currentTheme: self.changedTheme, fontSize: self.fontSize)
           }) {
            show(plantDetailController, sender: nil)
           }

    }
}

extension Notification.Name {
    static let requestForColor = Notification.Name("requestForColor")
    static let didReceiveColor = Notification.Name("didReceiveColor")
    static let requestForFontSize = Notification.Name("requestForFontSize")
    static let didReceiveFontSize = Notification.Name("didReceiveFontSize")
}

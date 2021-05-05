//
//  MapViewController.swift
//  laba1
//
//  Created by Ольга Ерохина on 4/27/21.
//

import UIKit
import MapKit
import CoreLocation


class MapViewController: UIViewController, MKMapViewDelegate {
    
    var plants: [Plant] = []
    let defaultRegionCordinage: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 53.893009, longitude: 27.567444)
    
    private let locationManager = CLLocationManager()
    
    @IBOutlet weak var mapView: MKMapView!
    

    
    @IBOutlet weak var mapNavigationBar: UINavigationBar!
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.post(name: .didReciveRequest, object: self)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpView()
        
        NotificationCenter.default.addObserver(self, selector: #selector(onDidReceiveData(_:)), name: .didReceiveData, object: nil)
        
       
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        
        if ThemeManager.isDarkMode() {
            enableDarkMode()
        }
        
    
    }
    
    func setUpView() {
        ThemeManager.addDarkModeObserver(to: self, selector: #selector(enableDarkMode))
    }
    
    @objc func enableDarkMode() {
        let currentTheme = ThemeManager.currentTheme
        
        mapNavigationBar.barTintColor = currentTheme.backgroundColorForNavigationBar
        mapNavigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: currentTheme.textColor]
        
    }
    
    @objc func onDidReceiveData(_ notification: Notification) {
        

        if let data = notification.userInfo as? [String: [Plant]] {
            plants = data["allItems"]!
            for plant in plants {
                print("MY PLANT \(plant)")
                
                let annotation = MKPointAnnotation()
                
                annotation.coordinate = CLLocationCoordinate2DMake(plant.mapX, plant.mapY)
                annotation.title = plant.name
                annotation.subtitle = plant.plantFamily
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

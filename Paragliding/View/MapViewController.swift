//
//  MapViewController.swift
//  Paragliding
//
//  Created by Stéphane Azzopardi on 04/12/2018.
//  Copyright © 2018 Stéphane Azzopardi. All rights reserved.
//

import UIKit
import MapKit
import Moya
import SwifterSwift

class MapViewController: UIViewController {

    // MARK: - Properties
    var locationManager                         = CLLocationManager()
    var isLocationAuthorizationChangeFirstCall  = true
    var isCenterMapRequested                    = false
    var userLocation: CLLocation?

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var centerMapButtonContainerView: UIVisualEffectView!
    @IBOutlet weak var centerMapButton: UIButton!

    // MARK: - Methods
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setup()
        handleInitialLocationAuthorizations()
    }

    private func setupUI() {
        mapView.showsUserLocation = true
        centerMapButtonContainerView.roundCorners(.allCorners, radius: centerMapButtonContainerView.height / 2)

        updateCenterMapButton()
    }

    private func setup() {
        locationManager.delegate = self
        mapView.delegate = self

        APIHelper.getFFVLSites { (sites) in
            self.mapView.addAnnotations(sites)
            print("\(sites.count) FFVL sites")
        }
    }

    func updateCenterMapButton() {
        let isLocationEnabled = [CLAuthorizationStatus.authorizedWhenInUse,
                                 CLAuthorizationStatus.authorizedAlways].contains(CLLocationManager.authorizationStatus())

        centerMapButton.imageView?.tintColor = isLocationEnabled ? UIColor.white : UIColor.gray
    }

    func handleInitialLocationAuthorizations() {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedAlways, .authorizedWhenInUse:
            isCenterMapRequested = true
        case .denied, .restricted, .notDetermined:
            break
        }
    }

    func centerMapOnUserPosition() {
        guard let location = userLocation else {
            return
        }

        isCenterMapRequested = false
        mapView.setCenter(location.coordinate, animated: true)
    }
}

//MARK: - User actions
extension MapViewController {
    @IBAction func centerMapButtonPressed(_ sender: Any) {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedAlways, .authorizedWhenInUse:
            centerMapOnUserPosition()
        case .denied, .restricted:
            print("Show custom view with Setting link")
        case .notDetermined:
            isCenterMapRequested = true
            locationManager.requestWhenInUseAuthorization()
        }
    }
}

//MARK: - CLLocationManagerDelegate
extension MapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        guard isLocationAuthorizationChangeFirstCall == false else {
            isLocationAuthorizationChangeFirstCall = false
            return
        }

        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            if isCenterMapRequested == true {
                centerMapOnUserPosition()
            }
        default:
            break
        }

        updateCenterMapButton()
    }
}

//MARK: - MKMapViewDelegate
extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        self.userLocation = userLocation.location

        if isCenterMapRequested == true {
            centerMapOnUserPosition()
        }
    }
}

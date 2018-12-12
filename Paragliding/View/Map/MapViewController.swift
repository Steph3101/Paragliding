//
//  MapViewController.swift
//  Paragliding
//
//  Created by Stéphane Azzopardi on 04/12/2018.
//  Copyright © 2018 Stéphane Azzopardi. All rights reserved.
//

import UIKit
import Mapbox
import SwifterSwift
import ClusterKit

public let CKClusterReuseIdentifier = "cluster"
public let CKAnnotationReuseIdentifier = "annotation"

class MapViewController: UIViewController {

    // MARK: - Properties
    var locationManager                         = CLLocationManager()
    var isLocationAuthorizationChangeFirstCall  = true
    var isCenterMapRequested                    = false
    var userLocation: MGLUserLocation?

    @IBOutlet weak var mapView: ASMGLMapView!
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
        let algorithm = CKNonHierarchicalDistanceBasedAlgorithm()
        algorithm.cellSize = 500
        mapView.clusterManager.algorithm = algorithm

        locationManager.delegate = self
        mapView.delegate = self

        MapViewModel.shared.getSites { (sites: [MKAnnotation]) in
            self.mapView.clusterManager.annotations = sites
        }
    }

    func updateCenterMapButton() {
        let isLocationEnabled = [CLAuthorizationStatus.authorizedWhenInUse,
                                 CLAuthorizationStatus.authorizedAlways].contains(CLLocationManager.authorizationStatus())

        centerMapButton.imageView?.tintColor = isLocationEnabled ? Color.white : Color.gray
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

    func showSettingsAlert() {
        let alert = UIAlertController(title: L10n.Map.LocationAlert.title,
                                      message: L10n.Map.LocationAlert.message(SwifterSwift.deviceModel, SwifterSwift.appDisplayName ?? ""),
                                      defaultActionButtonTitle: L10n.Common.cancel,
                                      tintColor: Color.orange)

        alert.addAction(UIAlertAction(title: L10n.Common.settings,
                                      style: .default,
                                      handler: { (alertAction) in
                                        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                                            return
                                        }

                                        if UIApplication.shared.canOpenURL(settingsUrl) {
                                            UIApplication.shared.open(settingsUrl, completionHandler: nil)
                                        }
        }))

        alert.show(animated: true, hapticFeedback: true, completion: nil)
    }
}

//MARK: - User actions
extension MapViewController {
    @IBAction func centerMapButtonPressed(_ sender: Any) {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedAlways, .authorizedWhenInUse:
            centerMapOnUserPosition()
        case .denied, .restricted:
            showSettingsAlert()
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

//MARK: - MGLMapViewDelegate
extension MapViewController: MGLMapViewDelegate {
    func mapView(_ mapView: MGLMapView, didUpdate userLocation: MGLUserLocation?) {
        self.userLocation = userLocation

        if isCenterMapRequested == true {
            centerMapOnUserPosition()
        }
    }

    //MARK: ClusterKit
    func mapView(_ mapView: MGLMapView, imageFor annotation: MGLAnnotation) -> MGLAnnotationImage? {
        guard let cluster = annotation as? CKCluster else {
            return nil
        }

        if cluster.count > 1 {
            if let clusterView = mapView.dequeueReusableAnnotationImage(withIdentifier: CKClusterReuseIdentifier) {
                return clusterView
            }

            let clusterView = MGLAnnotationImage(image: Asset.mapCluster.image, reuseIdentifier: CKClusterReuseIdentifier)
            return clusterView
        }

        if let annotationView = mapView.dequeueReusableAnnotationImage(withIdentifier: CKAnnotationReuseIdentifier) {
            return annotationView
        }

        let annotationView = MGLAnnotationImage(image: Asset.mapAnnotation.image, reuseIdentifier: CKAnnotationReuseIdentifier)
        return annotationView
    }

    func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        guard let cluster = annotation as? CKCluster else {
            return true
        }

        return cluster.count == 1
    }

    func mapView(_ mapView: MGLMapView, regionDidChangeAnimated animated: Bool) {
        mapView.clusterManager.updateClustersIfNeeded()
    }

    func mapView(_ mapView: MGLMapView, didSelect annotation: MGLAnnotation) {
        guard let cluster = annotation as? CKCluster else {
            return
        }

        if cluster.count > 1 {

            let edgePadding = UIEdgeInsets(top: 40, left: 20, bottom: 44, right: 20)
            let camera = mapView.cameraThatFitsCluster(cluster, edgePadding: edgePadding)
            mapView.setCamera(camera, animated: true)

        } else if let annotation = cluster.firstAnnotation {
            mapView.clusterManager.selectAnnotation(annotation, animated: false);
        }
    }

    func mapView(_ mapView: MGLMapView, didDeselect annotation: MGLAnnotation) {
        guard let cluster = annotation as? CKCluster, cluster.count == 1 else {
            return
        }

        mapView.clusterManager.deselectAnnotation(cluster.firstAnnotation, animated: false);
    }
}


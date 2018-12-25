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

private let kCKClusterReuseIdentifier       = "cluster"
private let kCKAnnotationReuseIdentifier    = "annotation"
private let kUserZoomLevel                  = 11.0
private let kInitialZoomLevel               = 4.0

class MapViewController: UIViewController {

    // MARK: - Properties
    lazy var mapViewModel: MapViewModel = {
        return MapViewModel()
    }()
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
        setupMapView()
        setupViewModel()
        handleInitialLocationAuthorizations()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        pulleyViewController?.animationDuration = 0.6
    }

    private func setupUI() {
        mapView.showsUserLocation = true
        centerMapButtonContainerView.roundCorners(.allCorners, radius: centerMapButtonContainerView.height / 2)

        updateCenterMapButton()
    }

    private func setupMapView() {
        locationManager.delegate        = self
        mapView.isRotateEnabled         = false
        mapView.showsScale              = true
        mapView.isHapticFeedbackEnabled = true
        mapView.delegate                = self

        let algorithm = CKNonHierarchicalDistanceBasedAlgorithm()
        algorithm.cellSize = 150
        
        mapView.clusterManager.algorithm    = algorithm
        mapView.clusterManager.marginFactor = 1
    }

    func setupViewModel() {
        mapViewModel.addAnnotationsClosure = { [weak self] () in
            guard let strongSelf = self else { return }
            strongSelf.mapView.clusterManager.annotations = strongSelf.mapViewModel.annotations
        }

        mapViewModel.getSites()
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
            centerMapOnDefaultPosition()
        }
    }

    func centerMapOnUser() {
        guard let location = userLocation else {
            return
        }

        isCenterMapRequested = false
        centerMap(location.coordinate, zoomLevel: max(kUserZoomLevel, mapView.zoomLevel), animated: true)
    }

    func centerMapOnDefaultPosition() {
        // France, somewhere in the middle
        let center = CLLocationCoordinate2D(latitude: 47.824905, longitude:  2.618787)
        centerMap(center, zoomLevel: kInitialZoomLevel, animated: false)
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

    func centerMap(_ coordinate: CLLocationCoordinate2D, zoomLevel: Double, animated: Bool = true) {
        mapView.setCenter(coordinate, zoomLevel: zoomLevel, direction: 0, animated: animated)
    }
}

// MARK: - User actions
extension MapViewController {
    @IBAction func centerMapButtonPressed(_ sender: Any) {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedAlways, .authorizedWhenInUse:
            centerMapOnUser()
        case .denied, .restricted:
            showSettingsAlert()
        case .notDetermined:
            isCenterMapRequested = true
            locationManager.requestWhenInUseAuthorization()
        }
    }
}

// MARK: - CLLocationManagerDelegate
extension MapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        // Hack because this method is always called twice at start
        guard isLocationAuthorizationChangeFirstCall == false else {
            isLocationAuthorizationChangeFirstCall = false
            return
        }

        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            mapView.showsUserLocation = true

            if isCenterMapRequested == true {
                centerMapOnUser()
            }
        default:
            break
        }

        updateCenterMapButton()
    }
}

// MARK: - MGLMapViewDelegate
extension MapViewController: MGLMapViewDelegate {
    func mapView(_ mapView: MGLMapView, didUpdate userLocation: MGLUserLocation?) {
        self.userLocation = userLocation

        if isCenterMapRequested == true {
            centerMapOnUser()
        }
    }

    // MARK: ClusterKit
    func mapView(_ mapView: MGLMapView, viewFor annotation: MGLAnnotation) -> MGLAnnotationView? {
        guard let cluster = annotation as? CKCluster else {
            return nil
        }

        if cluster.count > 1 {
            if let clusterView = mapView.dequeueReusableAnnotationView(withIdentifier: kCKClusterReuseIdentifier) as? ClusterAnnotationView {
                clusterView.setup(withCount: cluster.count)
                return clusterView
            }
            return ClusterAnnotationView(annotation: annotation, reuseIdentifier: kCKClusterReuseIdentifier, count: cluster.count)
        }

        guard let siteAnnotation = cluster.firstAnnotation,
            let siteAnnotationViewModel = mapViewModel.getSiteAnnotationViewModel(forAnnotation: siteAnnotation) else {
            return mapView.dequeueReusableAnnotationView(withIdentifier: kCKAnnotationReuseIdentifier)
        }

        return  SiteAnnotationView(annotation: annotation, reuseIdentifier: kCKAnnotationReuseIdentifier, viewModel: siteAnnotationViewModel)
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

            let sidesPadding = SwifterSwift.screenWidth / 5
            let upAndBottomPadding = SwifterSwift.screenWidth / 6
            let edgePadding = UIEdgeInsets(top: upAndBottomPadding, left: sidesPadding, bottom: upAndBottomPadding, right: sidesPadding)
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

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
        handleInitialLocationAuthorizations()
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

//MARK: - User actions
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

//MARK: - CLLocationManagerDelegate
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

//MARK: - MGLMapViewDelegate
extension MapViewController: MGLMapViewDelegate {
    func mapView(_ mapView: MGLMapView, didUpdate userLocation: MGLUserLocation?) {
        self.userLocation = userLocation

        if isCenterMapRequested == true {
            centerMapOnUser()
        }
    }

    //MARK: ClusterKit
    func mapView(_ mapView: MGLMapView, viewFor annotation: MGLAnnotation) -> MGLAnnotationView? {
        guard let cluster = annotation as? CKCluster else {
            return nil
        }

        if cluster.count > 1 {
            return mapView.dequeueReusableAnnotationView(withIdentifier: kCKClusterReuseIdentifier) ??
                MBXClusterView(annotation: annotation, reuseIdentifier: kCKClusterReuseIdentifier)
        }

        return mapView.dequeueReusableAnnotationView(withIdentifier: kCKAnnotationReuseIdentifier) ??
            MBXAnnotationView(annotation: annotation, reuseIdentifier: kCKAnnotationReuseIdentifier)
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

// MARK: - Custom annotation view
class MBXAnnotationView: MGLAnnotationView {

    var imageView: UIImageView!

    override init(annotation: MGLAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        imageView = UIImageView(image: Asset.mapAnnotation.image)
        addSubview(imageView)
        frame = imageView.frame

        isDraggable = true
        centerOffset = CGVector(dx: 0.5, dy: 1)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("Not implemented")
    }

    override func setDragState(_ dragState: MGLAnnotationViewDragState, animated: Bool) {
        super.setDragState(dragState, animated: animated)

        switch dragState {
        case .starting:
            UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 0.5, options: [.curveLinear], animations: {
                self.transform = self.transform.scaledBy(x: 2, y: 2)
            })
        case .ending:
            UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 0.5, options: [.curveLinear], animations: {
                self.transform = CGAffineTransform.identity
            })
        default:
            break
        }
    }
}

class MBXClusterView: MGLAnnotationView {

    var imageView: UIImageView!

    override init(annotation: MGLAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        imageView = UIImageView(image: Asset.mapCluster.image)
        addSubview(imageView)
        frame = imageView.frame

        centerOffset = CGVector(dx: 0.5, dy: 1)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("Not implemented")
    }

}

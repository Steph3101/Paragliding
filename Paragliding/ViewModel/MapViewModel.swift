//
//  MapViewModel.swift
//  Paragliding
//
//  Created by Stéphane Azzopardi on 11/12/2018.
//  Copyright © 2018 Stéphane Azzopardi. All rights reserved.
//

import UIKit
import MapKit

class MapViewModel: NSObject {

    private var sites: [Site] = [Site]() {
        didSet {
            addAnnotationsClosure?()
        }
    }
    private var sitesAnnotationsViewModels: [SiteAnnotationViewModel] = [SiteAnnotationViewModel]()

    var annotations: [MKAnnotation] {
        return sites
    }

    var addAnnotationsClosure: (()->())?

    func getSites() {
        APIHelper.getFFVLSites { (sites) in
            self.sites = sites
            self.sitesAnnotationsViewModels.removeAll()
            self.sites.forEach({ (site) in
                self.sitesAnnotationsViewModels.append(SiteAnnotationViewModel(site: site))
            })
        }
    }

    func getSiteAnnotationViewModel(forAnnotation annotation: MKAnnotation) -> SiteAnnotationViewModel? {
        guard let site = annotation as? Site else { return nil }
        return sitesAnnotationsViewModels.filter({ (siteViewModel) -> Bool in
            return siteViewModel.site == site
        }).first
    }
}

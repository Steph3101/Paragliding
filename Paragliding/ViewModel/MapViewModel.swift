//
//  MapViewModel.swift
//  Paragliding
//
//  Created by Stéphane Azzopardi on 11/12/2018.
//  Copyright © 2018 Stéphane Azzopardi. All rights reserved.
//

import UIKit
import Mapbox

class MapViewModel: NSObject {

    static let shared = MapViewModel()

    private var sites: [Site] = [Site]()

    func getSites(completion: (([MGLAnnotation]) -> ())? = nil) {
        guard let completion = completion else {
            return
        }

        if sites.count > 0 {
            completion(sites)
        } else {
            APIHelper.getFFVLSites { (sites) in
                self.sites = sites
                completion(sites)
            }
        }
    }
}

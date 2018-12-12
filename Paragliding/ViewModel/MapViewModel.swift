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

    static let shared = MapViewModel()

    private var sites: [Site] = [Site]()

    func getSites(completion: (([MKAnnotation]) -> ())? = nil) {
        guard let completion = completion else {
            return
        }

        if sites.count > 0 {
            completion(sites)
        } else {
            APIHelper.getFFVLSites { (sites) in
                print("Sites count : \(sites.count)")
                self.sites = sites
                completion(sites)
            }
        }
    }
}

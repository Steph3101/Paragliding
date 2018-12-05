//
//  MapViewController.swift
//  Paragliding
//
//  Created by Stéphane Azzopardi on 04/12/2018.
//  Copyright © 2018 Stéphane Azzopardi. All rights reserved.
//

import UIKit
import Moya

class MapViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        APIHelper.getFFVLSites { (sites) in
            sites.forEach({ (site) in
                print(site.name ?? "")
            })
        }
    }
}

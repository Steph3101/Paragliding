//
//  MainTabBarViewController.swift
//  Paragliding
//
//  Created by Stéphane Azzopardi on 13/01/2019.
//  Copyright © 2019 Stéphane Azzopardi. All rights reserved.
//

import UIKit
import Pulley

class MainTabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
    }

    func setup() {
        let mapViewController       = StoryboardScene.Map.mapViewController.instantiate()
        let searchViewController    = StoryboardScene.Map.searchViewController.instantiate()

        searchViewController.searchViewModel.mapViewModel   = mapViewController.mapViewModel
        searchViewController.searchDelegate                 = mapViewController

        let mapPulleyViewController = PulleyViewController(contentViewController: mapViewController, drawerViewController: searchViewController)

        setViewControllers([mapPulleyViewController], animated: false)
    }
}

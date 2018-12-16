//
//  SiteAnnotationViewModel.swift
//  Paragliding
//
//  Created by Stéphane Azzopardi on 16/12/2018.
//  Copyright © 2018 Stéphane Azzopardi. All rights reserved.
//

import UIKit

class SiteAnnotationViewModel: NSObject {

    var site: Site?

    convenience init(site: Site) {
        self.init()

        self.site = site
    }

    var image: UIImage {
        guard let type = site?.type else { return UIImage () }

        switch type {
        case .takeOff:
            return Asset.mapTakeOff.image
        case .landing:
            return Asset.mapLanding.image
        default:
            return UIImage()
        }
    }
}

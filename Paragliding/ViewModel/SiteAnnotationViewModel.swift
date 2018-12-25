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

    var orientations: [Orientation]? {
        return site?.orientations
    }

    convenience init(site: Site) {
        self.init()

        self.site = site
    }

    var image: UIImage {
        guard let type = site?.type else { return UIImage () }

        switch type {
        case .takeOff, .winch:
            return Asset.mapTakeOff.image
        case .landing:
            return Asset.mapLanding.image
        }
    }
}

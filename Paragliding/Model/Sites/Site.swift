//
//  Site.swift
//  Paragliding
//
//  Created by Stéphane Azzopardi on 03/12/2018.
//  Copyright © 2018 Stéphane Azzopardi. All rights reserved.
//

import UIKit
import CoreLocation

enum Orientation: String {
    case N
    case NNE
    case NE
    case ENE
    case E
    case ESE
    case SE
    case SSE
    case S
    case SSW
    case SW
    case WSW
    case W
    case WNW
    case NW
    case NNW
    case undefined

    init(withFrenchNotation notation: String) {
        self = Orientation.init(rawValue: notation.replacingOccurrences(of: "O", with: "W")) ?? Orientation.undefined
    }
}

class Site: NSObject {
    var location: CLPlacemark?
    var name: String?
    var orientations: [Orientation]?
    var favorableWinds: [Orientation]?
    var unfavorableWinds: [Orientation]?
    var siteDescription: String?
}

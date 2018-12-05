//
//  Site.swift
//  Paragliding
//
//  Created by Stéphane Azzopardi on 03/12/2018.
//  Copyright © 2018 Stéphane Azzopardi. All rights reserved.
//

import UIKit
import MapKit

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

class Site: NSObject, MKAnnotation {
    var name: String?
    var coordinate: CLLocationCoordinate2D = kCLLocationCoordinate2DInvalid
    var orientations: [Orientation]?
    var favorableWinds: [Orientation]?
    var unfavorableWinds: [Orientation]?
    var siteDescription: String?
    var altitude: Int?
}

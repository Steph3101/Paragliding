//
//  Site.swift
//  Paragliding
//
//  Created by Stéphane Azzopardi on 03/12/2018.
//  Copyright © 2018 Stéphane Azzopardi. All rights reserved.
//

import UIKit
import MapKit

class Site: NSObject, MKAnnotation {
    var name: String?
    var coordinate: CLLocationCoordinate2D = kCLLocationCoordinate2DInvalid
    var orientations: [Orientation]?
    var favorableWinds: [Orientation]?
    var unfavorableWinds: [Orientation]?
    var siteDescription: String?
    var altitude: Int?

    var title: String? {
        return name
    }

    var subtitle: String? {
        guard let orientations = orientations else { return nil }
        
        return Orientation.string(fromOrientations: orientations)
    }
}

enum type {
    case takeOff
    case landing
}

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
    case undefined = ""

    init(withFrenchNotation notation: String) {
        self = Orientation.init(rawValue: notation.replacingOccurrences(of: "O", with: "W")) ?? Orientation.undefined
    }

    static func orientations(fromList list: String) -> [Orientation]? {
        let separator = list.contains(",") ? "," : ";"

        let orientations = list.components(separatedBy: separator)
        guard list.isEmpty == false, orientations.count > 0 else { return nil }

        return orientations.compactMap { (orientationString) -> Orientation? in
            return orientationString.isEmpty ? nil : Orientation(withFrenchNotation: orientationString)
        }
    }

    static func string(fromOrientations orientations: [Orientation]) -> String {
        let stringsOrientations = orientations.map { (orientation) -> String in
            return orientation.rawValue.localized()
        }

        return stringsOrientations.joined(separator: ", ")
    }
}

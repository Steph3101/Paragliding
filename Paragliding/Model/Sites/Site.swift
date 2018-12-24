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
    var orientations: [Orientation]? = [Orientation]()
    var favorableWinds: [Orientation]?
    var unfavorableWinds: [Orientation]?
    var siteDescription: String?
    var altitude: Int?
    var type: Type?
    var activities: [Activity]?

    var title: String? {
        return name
    }

    var subtitle: String? {
        guard let orientations = orientations else { return nil }
        
        return Orientation.string(fromOrientations: orientations)
    }
}

enum Type {
    case takeOff
    case landing
    case winch
}

enum Activity {
    case paragliding
    case speedRiding
    case hangGliding
}

enum Orientation: String, CaseIterable {
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

    var degrees: CGFloat {
        let sectionAngle: CGFloat = 360 / CGFloat(Orientation.allCases.count)
        switch self {
        case .N:    return sectionAngle * 0
        case .NNE:  return sectionAngle * 1
        case .NE:   return sectionAngle * 2
        case .ENE:  return sectionAngle * 3
        case .E:    return sectionAngle * 4
        case .ESE:  return sectionAngle * 5
        case .SE:   return sectionAngle * 6
        case .SSE:  return sectionAngle * 7
        case .S:    return sectionAngle * 8
        case .SSW:  return sectionAngle * 9
        case .SW:   return sectionAngle * 10
        case .WSW:  return sectionAngle * 11
        case .W:    return sectionAngle * 12
        case .WNW:  return sectionAngle * 13
        case .NW:   return sectionAngle * 14
        case .NNW:  return sectionAngle * 15
        }
    }

    var trigonometricDegrees: CGFloat {
        return degrees - 90
    }

    var radians: CGFloat {
        return trigonometricDegrees * CGFloat.pi / 180
    }

    init?(withFrenchNotation notation: String) {
        if let orientation = Orientation.init(rawValue: notation.replacingOccurrences(of: "O", with: "W")) {
            self = orientation
        } else {
            return nil
        }
    }

    static func orientations(fromList list: String) -> [Orientation]? {
        let separator = list.contains(",") ? "," : ";"

        let orientationsStrings = list.components(separatedBy: separator)
        guard list.isEmpty == false, orientationsStrings.count > 0 else { return nil }

        let orientations = orientationsStrings.compactMap { (orientationString) -> Orientation? in
            return orientationString.isEmpty ? nil : Orientation(withFrenchNotation: orientationString)
        }

        return orientations
    }

    static func string(fromOrientations orientations: [Orientation]) -> String {
        let stringsOrientations = orientations.map { (orientation) -> String in
            return orientation.rawValue.localized()
        }

        return stringsOrientations.joined(separator: ", ")
    }
}

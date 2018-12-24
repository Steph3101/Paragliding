//
//  FFVLSite.swift
//  Paragliding
//
//  Created by Stéphane Azzopardi on 04/12/2018.
//  Copyright © 2018 Stéphane Azzopardi. All rights reserved.
//

import Moya_SwiftyJSONMapper
import SwiftyJSON
import CoreLocation
import MapKit

class FFVLSite: Site, ALSwiftyJSONAble {

    var isFlyingActivity: Bool = false

    required init?(jsonData: JSON) {
        super.init()

        self.name               = jsonData["nom"].stringValue
        self.siteDescription    = jsonData["description"].stringValue
        self.altitude           = jsonData["alt"].intValue
        self.isFlyingActivity   = jsonData["site_type"].stringValue == "vol"
        self.type               = FFVLSite.type(fromString: jsonData["site_sous_type"].stringValue)
        self.activities         = FFVLSite.activities(fromList: jsonData["pratiques"].stringValue)

        // Orientations
        self.favorableWinds     = Orientation.orientations(fromList: jsonData["vent_favo"].stringValue)
        self.unfavorableWinds   = Orientation.orientations(fromList: jsonData["vent_defavo"].stringValue)

        let orientationsValue = jsonData["orientation"].stringValue
        if orientationsValue.uppercased() == "TOUTES" {
            self.orientations = Orientation.allCases
        } else {
            self.orientations = Orientation.orientations(fromList: orientationsValue)
        }

        // Map coordinates
        let latitude    = Double(jsonData["lat"].stringValue)
        let longitude   = Double(jsonData["lon"].stringValue)
        if let latitude = latitude, let longitude = longitude, latitude != 0, longitude != 0 {
            self.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        }
    }

    private static func type(fromString string: String) -> Type? {
        switch string {
        case "Décollage":
            return Type.takeOff
        case "Atterrissage":
            return Type.landing
        case "Plateforme de treuil":
            return Type.winch
        default:
            return nil
        }
    }

    // Return a array of activities from a string list. Ex: "parapente;delta;0;0;0"
    private static func activities(fromList list: String) -> [Activity]? {
        let separator = list.contains(",") ? "," : ";"

        let activities = list.components(separatedBy: separator)
        guard list.isEmpty == false, activities.count > 0 else { return nil }

        return activities.compactMap { (activityString) -> Activity? in
            switch activityString {
            case "speed-riding":
                return Activity.speedRiding
            case "delta":
                return Activity.hangGliding
            case "parapente":
                return Activity.paragliding
            default:
                return nil
            }
        }
    }
}

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
    
    required init?(jsonData: JSON) {
        super.init()

        self.name               = jsonData["nom"].stringValue
        self.siteDescription    = jsonData["description"].stringValue
        self.altitude           = jsonData["alt"].intValue
        
        // Map coordinates
        let latitude    = Double(jsonData["lat"].stringValue)
        let longitude   = Double(jsonData["lon"].stringValue)
        if let latitude = latitude, let longitude = longitude, latitude != 0, longitude != 0 {
            self.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        }
    }
}

//
//  FFVLSite.swift
//  Paragliding
//
//  Created by Stéphane Azzopardi on 04/12/2018.
//  Copyright © 2018 Stéphane Azzopardi. All rights reserved.
//

import Moya_SwiftyJSONMapper
import SwiftyJSON

class FFVLSite: Site, ALSwiftyJSONAble {
    required init?(jsonData: JSON) {
        super.init()

        self.name = jsonData["nom"].stringValue
    }
}

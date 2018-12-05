//
//  APIHelper.swift
//  Paragliding
//
//  Created by Stéphane Azzopardi on 04/12/2018.
//  Copyright © 2018 Stéphane Azzopardi. All rights reserved.
//

import Moya
import Moya_SwiftyJSONMapper
import SwiftyJSON

class APIHelper: NSObject {

    private static let FFVLProvider = MoyaProvider<FFVLAPI>()

    static func getFFVLSites(completion: (([Site]) -> ())? = nil) {
        FFVLProvider.request(.getSites) { result in
            switch result {
            case let .success(response):
                do {
                    let sites = try response.map(to: [FFVLSite.self])

                    if let completion = completion {
                        completion(sites)
                    }
                } catch {
                    print(error)
                }
            case let .failure(error):
                print(error)
            }
        }
    }
}

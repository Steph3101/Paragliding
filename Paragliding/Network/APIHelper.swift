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
import CoreLocation

class APIHelper: NSObject {

    // Default provider
//    private static let FFVLProvider = MoyaProvider<FFVLAPI>()

    // Stubbed provider
    private static let FFVLProvider = MoyaProvider<FFVLAPI>(stubClosure: MoyaProvider.immediatelyStub)

    // Logged provider
//        private static let FFVLProvider = MoyaProvider<FFVLAPI>(plugins: [NetworkLoggerPlugin(verbose: true)])

    static func getFFVLSites(completion: (([Site]) -> ())? = nil) {
        FFVLProvider.request(.getSites) { result in
            switch result {
            case let .success(response):
                do {
                    let sites = try response.map(to: [FFVLSite.self]).filter({ (site) -> Bool in
                        return CLLocationCoordinate2DIsValid(site.coordinate) && (site.activities?.count ?? 0) > 0
                    })

                    if let completion = completion {
                        completion(sites)
                    }
                } catch {
                    // TODO: handle error
                    print(error)
                }
            case let .failure(error):
                // TODO: handle failure
                print(error)
            }
        }
    }
}

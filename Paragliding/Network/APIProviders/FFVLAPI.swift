//
//  FFVLAPIProvider.swift
//  Paragliding
//
//  Created by Stéphane Azzopardi on 04/12/2018.
//  Copyright © 2018 Stéphane Azzopardi. All rights reserved.
//

import Moya

enum FFVLAPI {
    case getSites
}

extension FFVLAPI: TargetType {
    var baseURL: URL { return URL(string: "https://data.ffvl.fr/json/")! }

    var path: String {
        switch self {
        case .getSites:
            return "sites.json"
        }
    }

    var method: Method {
        switch self {
        case .getSites:
            return .get
        }
    }

    var sampleData: Data {
        switch self {
        case .getSites:
            guard let url = Bundle.main.url(forResource: "getSites", withExtension: "json"),
                let data = try? Data(contentsOf: url) else {
                    return Data()
            }
            return data
        }
    }

    var task: Task {
        switch self {
        case .getSites:
            return .requestPlain
        }
    }

    var headers: [String : String]? {
        return ["Content-type": "application/json"]
    }
}

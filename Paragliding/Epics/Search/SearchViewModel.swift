//
//  SearchViewModel.swift
//  Paragliding
//
//  Created by Stéphane Azzopardi on 12/01/2019.
//  Copyright © 2019 Stéphane Azzopardi. All rights reserved.
//

import UIKit

enum SearchResult {
    case site(Site)

    var title: String? {
        switch self {
        case .site(let site):
            return site.name
        }
    }
}

final class SearchViewModel: NSObject {

    private var sites: [Site]? {
        return mapViewModel?.sites
    }

    private var searchResults: [SearchResult]? {
        didSet {
            updateSearchResultsClosure?()
        }
    }

    var searchText: String? {
        didSet {
            updateSearchResults()
        }
    }

    var mapViewModel: MapViewModel?
    var updateSearchResultsClosure: (()->())?
    var rowsCount: Int {
        return searchResults?.count ?? 0
    }

    private func updateSearchResults() {
        guard let searchText = searchText else {
            searchResults = [SearchResult]()
            return
        }

        searchResults = sites?.filter({ (site) -> Bool in
            return site.name?.localizedCaseInsensitiveContains(searchText) == true
        }).map({ (site) -> SearchResult in
            return SearchResult.site(site)
        })
    }

    func title(forIndexPath indexPath: IndexPath) -> String {
        return searchResults?[indexPath.row].title ?? "--"
    }
}

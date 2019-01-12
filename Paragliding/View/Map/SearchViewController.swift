//
//  SearchViewController.swift
//  Paragliding
//
//  Created by Stéphane Azzopardi on 25/12/2018.
//  Copyright © 2018 Stéphane Azzopardi. All rights reserved.
//

import UIKit
import Pulley
import SwifterSwift

final class SearchViewController: UIViewController {

    // MARK: - Properties
    @IBOutlet var tableView: UITableView!
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var gripperView: UIView!

    @IBOutlet weak var headerSectionHeightConstraint: NSLayoutConstraint!

    let headerHeight: CGFloat = 68.0

    fileprivate var drawerBottomSafeArea: CGFloat = 0.0 {
        didSet {
            self.loadViewIfNeeded()

            // We'll configure our UI to respect the safe area. In our small demo app, we just want to adjust the contentInset for the tableview.
            tableView.contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: drawerBottomSafeArea, right: 0.0)
        }
    }

    // MARK: - Methods
    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
        setupUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if #available(iOS 10.0, *)
        {
            let feedbackGenerator = UISelectionFeedbackGenerator()
            self.pulleyViewController?.feedbackGenerator = feedbackGenerator
        }
    }

    private func setup() {
        searchBar.delegate      = self
        tableView.delegate      = self
        tableView.dataSource    = self
    }

    private func setupUI() {
        tableView.tableFooterView = UIView()

        searchBar.placeholder = L10n.Search.SearchBar.placeholder

        gripperView.cornerRadius = gripperView.height / 2
    }
}

// MARK: - User actions
extension SearchViewController {

}

// MARK: - UITextFieldDelegate
extension SearchViewController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        pulleyViewController?.setDrawerPosition(position: .open, animated: true)
    }
}

// MARK: - PulleyDrawerViewControllerDelegate
extension SearchViewController: PulleyDrawerViewControllerDelegate {

    func supportedDrawerPositions() -> [PulleyPosition] {
        return [.closed, .collapsed, .open]
    }

    func collapsedDrawerHeight(bottomSafeArea: CGFloat) -> CGFloat
    {
        return headerHeight + bottomSafeArea
    }

    func drawerPositionDidChange(drawer: PulleyViewController, bottomSafeArea: CGFloat) {
        drawerBottomSafeArea = bottomSafeArea

        if drawer.drawerPosition != .open
        {
            searchBar.resignFirstResponder()
        }

        if drawer.drawerPosition == .collapsed
        {
            headerSectionHeightConstraint.constant = headerHeight + drawerBottomSafeArea
        }
        else
        {
            headerSectionHeightConstraint.constant = headerHeight
        }

        tableView.isScrollEnabled = drawer.drawerPosition == .open
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension SearchViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 20
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let tableViewCell = UITableViewCell()

        tableViewCell.textLabel?.text = "Result \(indexPath.row + 1)"

        return tableViewCell
    }

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        searchBar.resignFirstResponder()
    }
}

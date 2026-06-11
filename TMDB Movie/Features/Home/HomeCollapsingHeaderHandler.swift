//
//  HomeCollapsingHeaderHandler.swift
//  TMDB Movie
//

import UIKit

/// Gerencia altura dinâmica e progresso de colapso do header da Home durante o scroll.
final class HomeCollapsingHeaderHandler {

    private weak var tableView: UITableView?
    private let headerView: HomeHeaderView
    private(set) var baseHeaderHeight: CGFloat = 0

    init(tableView: UITableView, headerView: HomeHeaderView) {
        self.tableView = tableView
        self.headerView = headerView
    }

    func updateLayoutIfNeeded() {
        guard let tableView, tableView.bounds.width > 0 else { return }
        let resolved = tableView.applyTableHeader(headerView, width: tableView.bounds.width)
        if abs(baseHeaderHeight - resolved) > 0.5 {
            baseHeaderHeight = resolved
        }
    }

    func handleScroll(_ scrollView: UIScrollView) {
        guard scrollView === tableView, baseHeaderHeight > 0 else { return }

        let offset = scrollView.contentOffset.y
        if offset <= 0 {
            updateHeaderHeight(baseHeaderHeight - offset)
            headerView.applyScrollProgress(0)
            return
        }

        updateHeaderHeight(baseHeaderHeight)
        let progress = min(1, offset / 72.0)
        headerView.applyScrollProgress(progress)
    }

    private func updateHeaderHeight(_ height: CGFloat) {
        guard let tableView, tableView.bounds.width > 0 else { return }
        headerView.frame.size.height = height
        headerView.frame.size.width = tableView.bounds.width
        tableView.tableHeaderView = headerView
        tableView.tableHeaderView = headerView
    }
}

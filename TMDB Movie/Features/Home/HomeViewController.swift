//
//  HomeViewController.swift
//  TMDB Movie
//
//  Created by Arthur Ferreira on 30/12/25.
//
import UIKit

final class HomeViewController: UIViewController {

    var onSelectPoster: ((PosterItem) -> Void)?
    var onTapFavorites: (() -> Void)?

    private let viewModel: HomeViewModel
    private let imageLoader: ImageLoaderProtocol

    private let backgroundView = GradientBackgroundView(style: .purpleToDarkPurpleToBlack)
    private let headerView = HomeHeaderView()
    private let bottomTabBar = HomeBottomTabBarView()

    private var sections: [HomeSection] = []
    private var debounceWorkItem: DispatchWorkItem?
    private var isLoading: Bool = false
    private var animatedRowIDs: Set<String> = []
    private lazy var headerScrollHandler = HomeCollapsingHeaderHandler(
        tableView: tableView,
        headerView: headerView
    )
    private let selectionHaptic = UIImpactFeedbackGenerator(style: .light)
    private let filterHaptic = UISelectionFeedbackGenerator()
    private let feedbackView = DSFeedbackView()

    private lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.backgroundColor = .clear
        tv.separatorStyle = .none
        tv.showsVerticalScrollIndicator = false
        tv.dataSource = self
        tv.delegate = self
        tv.register(HomeCarouselTableCell.self, forCellReuseIdentifier: HomeCarouselTableCell.reuseIdentifier)
        tv.register(PosterGridTableCell.self, forCellReuseIdentifier: PosterGridTableCell.reuseIdentifier)
        tv.rowHeight = UITableView.automaticDimension
        tv.estimatedRowHeight = 274
        tv.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 118, right: 0)
        tv.verticalScrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 118, right: 0)
        return tv
    }()

    init(viewModel: HomeViewModel, imageLoader: ImageLoaderProtocol) {
        self.viewModel = viewModel
        self.imageLoader = imageLoader
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { nil }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = DSColors.background
        bottomTabBar.delegate = self
        selectionHaptic.prepare()
        filterHaptic.prepare()
        setupView()
        bind()
        bindHeader()
        viewModel.loadInitial()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if navigationController?.topViewController === self {
            bottomTabBar.prepareForReuseOnAppear()
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        headerView.updateTopInset(view.safeAreaInsets.top)
        headerScrollHandler.updateLayoutIfNeeded()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        debounceWorkItem?.cancel()
        viewModel.cancel()
    }

    deinit {
        debounceWorkItem?.cancel()
    }

    private func bind() {
        viewModel.onStateChange = { [weak self] state in
            guard let self else { return }
            self.headerView.configureGenres(state.genres)
            self.headerView.setCatalog(state.catalog == .movie ? .movie : .tv)
            self.sections = state.sections
            self.isLoading = (state.status == .loading)

            self.applyFeedback(for: state, using: self.feedbackView) { [weak self] in
                self?.viewModel.loadInitial()
            }
            self.tableView.alpha = state.status == .loading ? 0.96 : 1.0

            if state.status != .loading {
                self.animatedRowIDs.removeAll()
            }

            UIView.performWithoutAnimation {
                self.tableView.reloadData()
            }
        }
    }

    private func bindHeader() {
        headerView.onTextChange = { [weak self] text in
            guard let self else { return }
            self.debounceWorkItem?.cancel()

            let work = DispatchWorkItem { [weak self] in
                guard let self else { return }
                Task { @MainActor in self.viewModel.search(query: text) }
            }

            self.debounceWorkItem = work
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35, execute: work)
        }

        headerView.onSearch = { [weak self] text in
            guard let self else { return }
            self.debounceWorkItem?.cancel()
            self.selectionHaptic.impactOccurred()
            Task { @MainActor in self.viewModel.search(query: text) }
            self.view.endEditing(true)
        }

        headerView.onSelectGenreIndex = { [weak self] idx in
            guard let self else { return }
            self.debounceWorkItem?.cancel()
            self.headerView.setSearchText("")
            self.view.endEditing(true)
            self.filterHaptic.selectionChanged()
            Task { @MainActor in self.viewModel.selectGenre(index: idx) }
        }

        headerView.onSelectCatalog = { [weak self] kind in
            guard let self else { return }
            self.debounceWorkItem?.cancel()
            self.headerView.setSearchText("")
            self.view.endEditing(true)
            self.filterHaptic.selectionChanged()
            let catalog: HomeViewModel.Catalog = kind == .movie ? .movie : .tv
            Task { @MainActor in self.viewModel.selectCatalog(catalog) }
        }
    }

    private func scrollTableToTop(animated: Bool) {
        tableView.setContentOffset(
            CGPoint(x: 0, y: -tableView.adjustedContentInset.top),
            animated: animated
        )
    }
}

extension HomeViewController: HomeBottomTabBarViewDelegate {

    func homeBottomTabBarDidSelectHome(_ tabBar: HomeBottomTabBarView) {
        scrollTableToTop(animated: true)
    }

    func homeBottomTabBarDidSelectFavorites(_ tabBar: HomeBottomTabBarView) {
        onTapFavorites?()
    }
}

extension HomeViewController: ViewCodeType {

    func buildViewHierarchy() {
        view.addSubview(backgroundView)
        view.addSubview(tableView)
        view.addSubview(feedbackView)
        view.addSubview(bottomTabBar)
    }

    func setupConstraints() {
        backgroundView.anchor(
            top: view.topAnchor,
            left: view.leftAnchor,
            bottom: view.bottomAnchor,
            right: view.rightAnchor
        )

        tableView.anchor(
            top: view.topAnchor,
            left: view.leftAnchor,
            bottom: view.bottomAnchor,
            right: view.rightAnchor
        )

        NSLayoutConstraint.activate([
            feedbackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: DSSpacing.screenHorizontal),
            feedbackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -DSSpacing.screenHorizontal),
            feedbackView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 40),

            bottomTabBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: DSSpacing.screenHorizontal),
            bottomTabBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -DSSpacing.screenHorizontal),
            bottomTabBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10)
        ])
    }

    func setupAdditionalConfiguration() {
        navigationController?.setNavigationBarHidden(true, animated: false)
        bottomTabBar.prepareForReuseOnAppear()

        headerView.frame = CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 1)
        tableView.tableHeaderView = headerView
    }
}

extension HomeViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int { 1 }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        sections.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = sections[indexPath.row]

        if section.type.isSearch {
            let cell = tableView.dequeueReusableCell(
                withIdentifier: PosterGridTableCell.reuseIdentifier,
                for: indexPath
            ) as! PosterGridTableCell

            cell.configure(
                section: section,
                imageLoader: imageLoader,
                isLoadingMore: viewModel.state.isLoadingMoreSearch
            )
            cell.onSelectItem = { [weak self] item in
                self?.selectionHaptic.impactOccurred()
                self?.onSelectPoster?(item)
            }
            cell.onNearEnd = { [weak self] in
                Task { @MainActor in
                    self?.viewModel.loadMoreSearchIfNeeded()
                }
            }
            return cell
        }

        let cell = tableView.dequeueReusableCell(
            withIdentifier: HomeCarouselTableCell.reuseIdentifier,
            for: indexPath
        ) as! HomeCarouselTableCell

        cell.configure(section: section, imageLoader: imageLoader, isLoading: isLoading)

        cell.onSelect = { [weak self] item in
            self?.selectionHaptic.impactOccurred()
            self?.onSelectPoster?(item)
        }

        return cell
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat { 274 }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard indexPath.row < sections.count else { return }
        let rowID = sections[indexPath.row].type.title
        guard !animatedRowIDs.contains(rowID) else { return }
        animatedRowIDs.insert(rowID)

        guard !UIAccessibility.isReduceMotionEnabled else {
            cell.alpha = 1
            cell.transform = .identity
            return
        }

        cell.alpha = 0
        cell.transform = CGAffineTransform(translationX: 0, y: 14)
        UIView.animate(
            withDuration: 0.4,
            delay: 0.03 * Double(indexPath.row),
            usingSpringWithDamping: 0.92,
            initialSpringVelocity: 0.25,
            options: [.curveEaseOut, .allowUserInteraction]
        ) {
            cell.alpha = 1
            cell.transform = .identity
        }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView === tableView else { return }

        if viewModel.state.canLoadMoreSearch {
            let offsetY = scrollView.contentOffset.y
            let contentHeight = scrollView.contentSize.height
            let frameHeight = scrollView.frame.size.height
            if offsetY > contentHeight - frameHeight - 280 {
                viewModel.loadMoreSearchIfNeeded()
            }
        }

        headerScrollHandler.handleScroll(scrollView)
    }
}

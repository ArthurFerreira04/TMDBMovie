//
//  FavoritesViewModel.swift
//  TMDB Movie
//

import Foundation

@MainActor
final class FavoritesViewModel {

    struct ViewState: Equatable {
        let items: [PosterItem]
        let countLabel: String
        let isEditing: Bool
        let showsEditControls: Bool
        let isEmpty: Bool

        static let empty = ViewState(
            items: [],
            countLabel: "",
            isEditing: false,
            showsEditControls: false,
            isEmpty: true
        )
    }

    var onStateChange: ((ViewState) -> Void)?

    private let store: FavoritesStoreProtocol
    private var observer: NSObjectProtocol?
    private var isEditing = false

    init(store: FavoritesStoreProtocol) {
        self.store = store
    }

    func start() {
        bindStoreObserver()
        reload()
    }

    func stop() {
        if let observer {
            NotificationCenter.default.removeObserver(observer)
            self.observer = nil
        }
    }

    func toggleEditMode() {
        isEditing.toggle()
        reload()
    }

    func removeItem(at index: Int) {
        let items = store.all().map(\.asPosterItem)
        guard items.indices.contains(index) else { return }
        let item = items[index]
        store.remove(id: item.id, mediaKind: item.mediaKind)
        reload()
    }

    func clearAll() {
        store.removeAll()
        isEditing = false
        reload()
    }

    private func bindStoreObserver() {
        observer = NotificationCenter.default.addObserver(
            forName: .favoritesDidChange,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                self?.reload()
            }
        }
    }

    private func reload() {
        let movies = store.all().map(\.asPosterItem)
        let count = movies.count

        if count == 0 {
            isEditing = false
        }

        let state = ViewState(
            items: movies,
            countLabel: countLabel(for: count),
            isEditing: isEditing && count > 0,
            showsEditControls: count > 0,
            isEmpty: count == 0
        )
        onStateChange?(state)
    }

    private func countLabel(for count: Int) -> String {
        switch count {
        case 0: return ""
        case 1: return "1 filme"
        default: return "\(count) filmes"
        }
    }
}

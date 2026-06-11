import XCTest
@testable import TMDB_Movie

final class HomePaginationTests: XCTestCase {

    @MainActor
    func testSearchLoadsFirstPageWithPaginationMetadata() {
        let service = TMDBServiceMock()
        service.searchMoviesResult = [
            .init(id: 1, title: "A", posterPath: nil, backdropPath: nil),
            .init(id: 2, title: "B", posterPath: nil, backdropPath: nil)
        ]

        let viewModel = HomeViewModel(service: service)
        let loaded = expectation(description: "first page loaded")

        viewModel.onStateChange = { state in
            if state.status == .loaded, state.canLoadMoreSearch {
                XCTAssertEqual(state.sections.first?.items.count, 2)
                loaded.fulfill()
            }
        }

        viewModel.search(query: "marvel")
        wait(for: [loaded], timeout: 1.0)
    }

    @MainActor
    func testLoadMoreSearchAppendsResults() {
        let service = TMDBServiceMock()
        service.searchMoviesResult = [
            .init(id: 1, title: "A", posterPath: nil, backdropPath: nil)
        ]

        let viewModel = HomeViewModel(service: service)
        let firstPage = expectation(description: "first page")
        let secondPage = expectation(description: "second page")

        var settledLoads = 0
        viewModel.onStateChange = { state in
            guard state.status == .loaded, !state.isLoadingMoreSearch else { return }
            settledLoads += 1
            if settledLoads == 1 {
                XCTAssertTrue(state.canLoadMoreSearch)
                XCTAssertEqual(state.sections.first?.items.count, 1)
                firstPage.fulfill()
            } else if settledLoads == 2 {
                XCTAssertEqual(state.sections.first?.items.count, 2)
                secondPage.fulfill()
            }
        }

        viewModel.search(query: "marvel")
        wait(for: [firstPage], timeout: 1.0)
        viewModel.loadMoreSearchIfNeeded()
        wait(for: [secondPage], timeout: 1.0)
    }

    @MainActor
    func testSearchEmptyPublishesEmptyState() {
        let service = TMDBServiceMock()
        service.searchMoviesResult = []

        let viewModel = HomeViewModel(service: service)
        let empty = expectation(description: "empty")

        viewModel.onStateChange = { state in
            if state.status == .empty {
                empty.fulfill()
            }
        }

        viewModel.search(query: "xyzinexistente")
        wait(for: [empty], timeout: 1.0)
    }
}

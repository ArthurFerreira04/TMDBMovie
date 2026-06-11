import XCTest
@testable import TMDB_Movie

final class HomeViewModelTests: XCTestCase {

    @MainActor
    func testLoadInitialPublishesLoadedStateWithSections() {
        let service = TMDBServiceMock()
        service.movieGenresResult = [.init(id: 1, name: "Acao")]
        service.trendingMoviesWeekResult = [
            .init(id: 101, title: "Movie A", posterPath: "/a.jpg", backdropPath: nil)
        ]
        service.popularMoviesResult = [
            .init(id: 201, title: "Movie B", posterPath: "/b.jpg", backdropPath: nil)
        ]

        let viewModel = HomeViewModel(service: service)
        let expectation = expectation(description: "state loaded")

        viewModel.onStateChange = { state in
            if state.status == .loaded {
                XCTAssertEqual(state.genres.count, 1)
                XCTAssertEqual(state.sections.count, 2)
                XCTAssertEqual(state.sections[0].items.count, 1)
                XCTAssertEqual(state.sections[1].items.count, 1)
                expectation.fulfill()
            }
        }

        viewModel.loadInitial()
        wait(for: [expectation], timeout: 1.0)
    }

    @MainActor
    func testSearchPublishesErrorStateWhenServiceFails() {
        let service = TMDBServiceMock()
        service.searchMoviesError = APIError.httpStatus(429, nil)
        let viewModel = HomeViewModel(service: service)
        let expectation = expectation(description: "state error")

        viewModel.onStateChange = { state in
            if case .error(let message) = state.status {
                XCTAssertEqual(message, "Muitas requisicoes. Aguarde e tente novamente.")
                expectation.fulfill()
            }
        }

        viewModel.search(query: "avatar")
        wait(for: [expectation], timeout: 1.0)
    }
}

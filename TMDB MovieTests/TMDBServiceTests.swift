import XCTest
@testable import TMDB_Movie

final class TMDBServiceTests: XCTestCase {

    func testPopularMoviesBuildsExpectedEndpoint() async throws {
        let client = APIClientMock()
        client.pagedMoviesStub = TMDBPagedResponseDTO(
            page: 1,
            results: [.init(id: 10, title: "Movie", posterPath: "/m.jpg", backdropPath: nil)],
            totalPages: 1,
            totalResults: 1
        )

        let sut = TMDBService(client: client)
        _ = try await sut.popularMovies(page: 3)

        XCTAssertEqual(client.lastEndpoint?.path, "movie/popular")
        XCTAssertEqual(client.lastEndpoint?.method, .get)
        XCTAssertEqual(client.lastEndpoint?.queryItems.first(where: { $0.name == "language" })?.value, "pt-BR")
        XCTAssertEqual(client.lastEndpoint?.queryItems.first(where: { $0.name == "page" })?.value, "3")
    }
}

private final class APIClientMock: APIClientProtocol {
    var lastEndpoint: Endpoint?
    var pagedMoviesStub: TMDBPagedResponseDTO<TMDBMovieDTO> = .init(page: 1, results: [], totalPages: 1, totalResults: 0)

    func send<T>(_ endpoint: Endpoint) async throws -> T where T : Decodable {
        lastEndpoint = endpoint

        if T.self == TMDBPagedResponseDTO<TMDBMovieDTO>.self {
            return pagedMoviesStub as! T
        }

        fatalError("Stub nao configurado para tipo \(T.self)")
    }

    func fetchData(_ url: URL) async throws -> Data {
        Data()
    }
}

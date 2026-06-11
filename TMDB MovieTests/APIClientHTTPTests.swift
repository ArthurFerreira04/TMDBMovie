import XCTest
@testable import TMDB_Movie

final class APIClientHTTPTests: XCTestCase {

    override func tearDown() {
        MockURLProtocol.requestHandler = nil
        super.tearDown()
    }

    func testSendMaps401ToHttpStatus() async {
        await assertHTTPError(statusCode: 401, expectedMessage: "Sessao invalida. Verifique as credenciais da API.")
    }

    func testSendMaps404ToHttpStatus() async {
        await assertHTTPError(statusCode: 404, expectedMessage: "Conteudo nao encontrado.")
    }

    func testSendMaps429ToHttpStatus() async {
        await assertHTTPError(statusCode: 429, expectedMessage: "Muitas requisicoes. Aguarde e tente novamente.")
    }

    private func assertHTTPError(statusCode: Int, expectedMessage: String) async {
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: statusCode,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, Data())
        }

        let client = makeClient()
        let endpoint = Endpoint(path: "movie/popular", method: .get, queryItems: [])

        do {
            let _: TMDBPagedResponseDTO<TMDBMovieDTO> = try await client.send(endpoint)
            XCTFail("Esperava erro HTTP \(statusCode)")
        } catch let error as APIError {
            guard case .httpStatus(let code, _) = error else {
                return XCTFail("Esperava APIError.httpStatus, recebeu \(error)")
            }
            XCTAssertEqual(code, statusCode)
            XCTAssertEqual(error.userMessage, expectedMessage)
        } catch {
            XCTFail("Erro inesperado: \(error)")
        }
    }

    private func makeClient() -> APIClient {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        let session = URLSession(configuration: config)
        return APIClient(
            baseURL: URL(string: "https://api.themoviedb.org/3/")!,
            bearerToken: "test-token",
            session: session
        )
    }
}

private final class MockURLProtocol: URLProtocol {
    static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data))?

    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        guard let handler = Self.requestHandler else {
            client?.urlProtocol(self, didFailWithError: URLError(.badURL))
            return
        }

        do {
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {}
}

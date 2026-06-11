import XCTest
@testable import TMDB_Movie

final class APIErrorUserMessageTests: XCTestCase {

    func testUserMessageForUnauthorizedError() {
        let error: Error = APIError.httpStatus(401, nil)
        XCTAssertEqual(error.userMessage, "Sessao invalida. Verifique as credenciais da API.")
    }

    func testUserMessageForNotFoundError() {
        let error: Error = APIError.httpStatus(404, nil)
        XCTAssertEqual(error.userMessage, "Conteudo nao encontrado.")
    }

    func testUserMessageForRateLimitError() {
        let error: Error = APIError.httpStatus(429, nil)
        XCTAssertEqual(error.userMessage, "Muitas requisicoes. Aguarde e tente novamente.")
    }

    func testUserMessageForUnknownError() {
        struct UnknownError: Error {}
        XCTAssertEqual(UnknownError().userMessage, "Ocorreu um erro inesperado. Tente novamente.")
    }
}

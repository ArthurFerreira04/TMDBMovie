//
//  APIError.swift
//  TMDB Movie
//
//  Created by Arthur Ferreira on 08/01/26.
//

import Foundation

enum APIError: Error, Equatable {
    case invalidURL
    case invalidResponse
    case httpStatus(Int, Data?)
    case decoding
    case cancelled
}

extension Error {
    var userMessage: String {
        guard let apiError = self as? APIError else {
            return "Ocorreu um erro inesperado. Tente novamente."
        }

        switch apiError {
        case .cancelled:
            return "Operacao cancelada."
        case .invalidURL:
            return "Nao foi possivel montar a requisicao."
        case .invalidResponse:
            return "Resposta invalida do servidor."
        case .decoding:
            return "Nao foi possivel processar os dados."
        case .httpStatus(let statusCode, _):
            switch statusCode {
            case 401:
                return "Sessao invalida. Verifique as credenciais da API."
            case 404:
                return "Conteudo nao encontrado."
            case 429:
                return "Muitas requisicoes. Aguarde e tente novamente."
            case 500...599:
                return "Servidor indisponivel no momento."
            default:
                return "Falha de comunicacao (codigo \(statusCode))."
            }
        }
    }
}

//
//  SummarizationServiceError.swift
//  AIMeetingTranscriber
//
//  Created by Zikar Nurizky on 02/01/26.
//

import Foundation

struct APIErrorResponse: Decodable {
    let error: APIErrorDetail
}

struct APIErrorDetail: Decodable {
    let message: String
    let type: String?
    let code: String?
}


enum SummarizationError: LocalizedError {
    case invalidResponse
    case billingInactive
    case rateLimited
    case serverError(String)
    case decodingError
    case unknown

    var errorDescription: String? {
        switch self {
        case .billingInactive:
            return "AI service unavailable (billing inactive). Integration ready."
        case .rateLimited:
            return "AI service is rate limited. Try again later."
        case .serverError(let message):
            return message
        case .invalidResponse:
            return "Invalid response from server."
        case .decodingError:
            return "Failed to decode server response."
        case .unknown:
            return "Unknown error occurred."
        }
    }
}

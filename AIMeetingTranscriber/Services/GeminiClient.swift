//
//  GeminiClient.swift
//  AIMeetingTranscriber
//
//  Created by Zikar Nurizky on 02/01/26.
//

import Foundation

final class GeminiClient: LLMClient {

    private let apiKey = APIConfig.geminiKey
    private let endpoint =
        "https://generativelanguage.googleapis.com/v1beta/models/gemini-3-pro-preview:generateContent"

    private func decodeBillingError(from data: Data) throws
        -> SummarizationError
    {
        let errorResponse = try JSONDecoder().decode(
            APIErrorResponse.self,
            from: data
        )

        if errorResponse.error.code == "billing_not_active"
            || errorResponse.error.code == "insufficient_quota"
        {
            return .billingInactive
        }

        return .serverError(errorResponse.error.message)
    }

    private func decodeServerError(from data: Data) throws -> SummarizationError
    {
        if let errorResponse = try? JSONDecoder().decode(
            APIErrorResponse.self,
            from: data
        ) {
            return .serverError(errorResponse.error.message)
        }
        return .unknown
    }

    func summarize(text: String) async throws -> String {

        let prompt = """
            You are an AI meeting assistant.
            Summarize the meeting into:
            - Key points
            - Action items
            - Decisions

            Meeting transcript:
            \(text)
            """

        let url = URL(string: "\(endpoint)?key=\(apiKey)")!
        print("🔑 Gemini API Key:", apiKey)
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = GeminiRequest(
            contents: [
                Content(
                    parts: [Part(text: prompt)]
                )
            ]
        )

        request.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw SummarizationError.invalidResponse
        }

        switch httpResponse.statusCode {

        case 200...299:
            let decoded = try JSONDecoder().decode(
                GeminiResponse.self,
                from: data
            )
            return decoded.candidates
                .first?
                .content
                .parts
                .first?
                .text ?? ""

        case 401, 402:
            throw try decodeBillingError(from: data)

        case 429:
            throw SummarizationError.rateLimited

        default:
            throw try decodeServerError(from: data)
        }
    }
}

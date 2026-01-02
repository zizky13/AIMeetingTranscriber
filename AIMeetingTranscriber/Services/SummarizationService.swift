//
//  SummarizationService.swift
//  AIMeetingTranscriber
//
//  Created by Zikar Nurizky on 26/12/25.
//

import Combine
import Foundation

enum APIConfig {
    static let geminiKey: String = {
        guard let key = Bundle.main.object(
            forInfoDictionaryKey: "GEMINI_API_KEY"
        ) as? String else {
            fatalError("GEMINI_API_KEY not found")
        }
        return key
    }()
}

final class SummarizationService: LLMClient {
    private let apiKey = APIConfig.geminiKey
    private let endpoint =
      "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent"
    
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

           guard let http = response as? HTTPURLResponse,
                 http.statusCode == 200 else {
               throw URLError(.badServerResponse)
           }

           let decoded = try JSONDecoder().decode(GeminiResponse.self, from: data)

           return decoded.candidates
               .first?
               .content
               .parts
               .first?
               .text ?? ""
       }
}

//
//  SummarizationService.swift
//  AIMeetingTranscriber
//
//  Created by Zikar Nurizky on 26/12/25.
//

import Combine
import Foundation

protocol SummarizationServiceProtocol {
    func summarize(text: String) async throws -> String
}
final class SummarizationService: SummarizationServiceProtocol {
    func summarize(text: String) async throws -> String {
        try await Task.sleep(nanoseconds: 1_000_000_000)
        return """
        Summary:
        - This is a dummy summary
        - Action item: Review implementation
        """
    }
}

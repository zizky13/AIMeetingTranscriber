//
//  SummarizationServiceProtocol.swift
//  AIMeetingTranscriber
//
//  Created by Zikar Nurizky on 02/01/26.
//

import Foundation

protocol LLMClient {
    func summarize(text: String) async throws -> String
}

//
//  GeminiResponse.swift
//  AIMeetingTranscriber
//
//  Created by Zikar Nurizky on 02/01/26.
//

import Foundation

struct GeminiResponse: Decodable {
    let candidates: [Candidate]
}

struct Candidate: Decodable {
    let content: ContentResponse
}

struct ContentResponse: Decodable {
    let parts: [PartResponse]
}

struct PartResponse: Decodable {
    let text: String
}

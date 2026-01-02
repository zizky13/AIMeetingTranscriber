//
//  GeminiRequest.swift
//  AIMeetingTranscriber
//
//  Created by Zikar Nurizky on 02/01/26.
//

import Foundation

struct GeminiRequest: Encodable {
    let contents: [Content]
}

struct Content: Encodable {
    let parts: [Part]
}

struct Part: Encodable {
    let text: String
}

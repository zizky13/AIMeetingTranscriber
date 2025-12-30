//
//  ContentViewViewModel.swift
//  AIMeetingTranscriber
//
//  Created by Zikar Nurizky on 26/12/25.
//

import Foundation
import Combine

enum SummaryState {
    case idle
    case loading
    case success(String)
    case error(String)
}

class HomeViewViewModel: ObservableObject {
    @Published var isRecording: Bool = false
    @Published var outputURL: URL? = nil
    @Published var meetingText: String = ""
    @Published var meetingSummary: String = ""
    private let speechRecognizer = SpeechRecognizerService()
    private let audioService = AudioRecordingService()
    private let summarizationService = SummarizationService()

    func requestPermission() async throws {
        try await audioService.requestPermission()
    }

    func startRecording() throws {
        try audioService.startRecording()
        isRecording = audioService.isRecording
        outputURL = audioService.outputURL
    }

    func stopRecording() {
        audioService.stopRecording()
        isRecording = audioService.isRecording
    }
    
    func startTextSummary() async throws {
        meetingSummary = try await summarizationService.summarize(text: meetingText)
    }
    
    func startAudioTranscribe() async throws {
        speechRecognizer.resetTranscript()
        speechRecognizer.startTranscribing()
        print("Start transcribingg....")
        isRecording = true
    }
    
    func endAudioTranscribe() {
        speechRecognizer.stopTranscribing()
        meetingText = speechRecognizer.transcript
        print("End transcribingg....")
        isRecording = false
    }
}

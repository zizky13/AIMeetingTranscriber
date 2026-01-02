//
//  ContentViewViewModel.swift
//  AIMeetingTranscriber
//
//  Created by Zikar Nurizky on 26/12/25.
//

import Combine
internal import CoreData
import Foundation

enum SummaryState {
    case idle
    case loading
    case success(String)
    case error(String)
}

class HomeViewViewModel: ObservableObject {
    
    //MARK: - UI State
    @Published var isRecording: Bool = false
    @Published var outputURL: URL? = nil
    @Published var meetingText: String = ""
    @Published var meetingSummary: String = ""
    @Published var state: SummaryState = .idle

    //MARK: - Services
    private let speechRecognizer = SpeechRecognizerService()
    private let audioService = AudioRecordingService()
    private let summarizationService = SummarizationService()

    //MARK: - Core Data
    private let context: NSManagedObjectContext

    // MARK: - Init
    init(context: NSManagedObjectContext) {
        self.context = context
    }

    // MARK: - Core Data Save
    func saveMeeting() {
        let meeting = MeetingRecord(context: context)
        meeting.id = UUID()
        meeting.title = "Meeting \(Date().formatted())"
        meeting.transcript = meetingText
        meeting.summary = meetingSummary
        meeting.createdAt = Date()

        do {
            try context.save()
            print("✅ Meeting saved to Core Data")
        } catch {
            print("❌ Core Data save error:", error.localizedDescription)
        }
    }

    //MARK: - Audio Permission
    func requestPermission() async throws {
        try await audioService.requestPermission()
    }

    // MARK: - Recording
    func startRecording() throws {
        try audioService.startRecording()
        isRecording = audioService.isRecording
        outputURL = audioService.outputURL
    }

    func stopRecording() {
        audioService.stopRecording()
        isRecording = audioService.isRecording
    }

    // MARK: - Summary + Persist
    func startTextSummaryAndSave() async {
        state = .loading

        do {
            let summary = try await summarizationService.summarize(text: meetingText)
            meetingSummary = summary
            state = .success(summary)

            saveMeeting()

        } catch let error as SummarizationError {
            state = .error(error.localizedDescription)

        } catch {
            state = .error("Unexpected error occurred.")
        }
    }
    
    // MARK: - Transcription
    func startAudioTranscribe() {
        speechRecognizer.resetTranscript()
        speechRecognizer.startTranscribing()
        isRecording = true
    }

    func endAudioTranscribe() {
        speechRecognizer.stopTranscribing()
        meetingText = speechRecognizer.transcript
        isRecording = false
    }
}

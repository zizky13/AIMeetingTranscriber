//
//  AudioCapture.swift
//  AIMeetingTranscriber
//
//  Created by Zikar Nurizky on 25/12/25.
//

import AVFoundation
import Combine
import Foundation

// Enum untuk recording error cases (BEST PRACTICE)
enum RecordingError: LocalizedError {
    case microphonePermissionDenied
    case recordingFailed

    // errorDescription akan keganti tergantung cases yg dideteksi
    var errorDescription: String? {
        switch self {
        case .microphonePermissionDenied:
            return "Microphone permission was denied."
        case .recordingFailed:
            return "Failed to start audio recording."
        }
    }
}

// Protocol AudioRecording -> Make it testable
protocol AudioRecordingServiceProtocol {
    var isRecording: Bool { get }
    var outputURL: URL? { get }

    func requestPermission() async throws
    func startRecording() throws
    func stopRecording()
}

// AudioRecordingService -> Comforms to NSObject, ObservableObject, AudioRecordingServiceProtocol
final class AudioRecordingService: NSObject,
    ObservableObject,
    AudioRecordingServiceProtocol
{

    // MARK: - Published State (SwiftUI-friendly)

    var isRecording: Bool = false
    var outputURL: URL?

    // MARK: - Private

    private let session = AVAudioSession.sharedInstance() // Singleton biar ga init ke instance beda
    private var recorder: AVAudioRecorder?

    // MARK: - Permissions
    /// Requests permission from the user to access the device's microphone.
    ///
    /// This asynchronous method presents a system prompt if necessary, asking the user to allow microphone access.
    /// - Throws: `RecordingError.microphonePermissionDenied` if the user denies microphone access.
    /// - Note: Call this method before attempting to start audio recording. You should handle the thrown error and inform users if permission is denied.
    /// - Important: This method must be called on the main thread, as it interacts with system UI.
    func requestPermission() async throws {
        let granted = await withCheckedContinuation { continuation in
            session.requestRecordPermission { granted in
                continuation.resume(returning: granted)
            }
        }

        if !granted {
            throw RecordingError.microphonePermissionDenied
        }
    }

    // MARK: - Recording Control

    func startRecording() throws {
        guard !isRecording else { return }

        try configureSession()

        let url = makeOutputURL()
        let settings = recordingSettings()

        recorder = try AVAudioRecorder(url: url, settings: settings)
        recorder?.record()

        outputURL = url
        isRecording = true
    }

    func stopRecording() {
        recorder?.stop()
        recorder = nil
        isRecording = false
        try? session.setActive(false)
    }

    // MARK: - Configuration

    private func configureSession() throws {
        try session.setCategory(
            .playAndRecord,
            mode: .default,
            options: [.defaultToSpeaker]
        )
        try session.setActive(true)
    }

    private func recordingSettings() -> [String: Any] {
        [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44_100,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue,
        ]
    }

    private func makeOutputURL() -> URL {
        FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        )[0]
        .appendingPathComponent("meeting-\(UUID().uuidString).m4a")
    }
}

//
//  RecordingResultView.swift
//  AIMeetingTranscriber
//
//  Created by Zikar Nurizky on 25/12/25.
//

import SwiftUI
internal import CoreData

struct RecordingResultView: View {
    let audioURL: URL

    @StateObject private var player = AudioPlaybackService()
    @StateObject private var viewModel: HomeViewViewModel
    
    init(audioURL: URL, context: NSManagedObjectContext) {
        self.audioURL = audioURL
        _viewModel = StateObject(
            wrappedValue: HomeViewViewModel(context: context)
        )
    }

    var body: some View {
        VStack(spacing: 24) {

            VStack(spacing: 8) {
                Text("Recording Saved")
                    .font(.title2)
                    .fontWeight(.semibold)

                Text(audioURL.lastPathComponent)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Button {
                togglePlayback()
            } label: {
                Label(
                    player.isPlaying ? "Stop Playback" : "Play Recording",
                    systemImage: player.isPlaying ? "stop.fill" : "play.fill"
                )
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)

            Divider()

            VStack(spacing: 12) {
                Button("Generate Transcript") {
                    // TODO: Hook STT pipeline
                }

                Button("Summarize Meeting") {
                    // TODO: Hook LLM summarization
                }
            }
            .frame(maxWidth: .infinity)

            Spacer()
        }
        .padding()
        .onAppear {
            try? player.load(url: audioURL)
        }
    }

    private func togglePlayback() {
        player.isPlaying ? player.stop() : player.play()
    }
}

#Preview {
    RecordingResultView(audioURL: URL(fileURLWithPath: "/dev/null"), context: NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType))
}

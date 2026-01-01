//
//  ContentView.swift
//  AIMeetingTranscriber
//
//  Created by Zikar Nurizky on 25/12/25.
//

internal import CoreData
import SwiftUI

struct HomeView: View {
    @Environment(\.managedObjectContext) private var context
    @StateObject private var viewModel: HomeViewViewModel
    @State private var showResult = false
    var meetingText: String = ""

    init(context: NSManagedObjectContext) {
        _viewModel = StateObject(
            wrappedValue: HomeViewViewModel(context: context)
        )
    }
    
    @FetchRequest(
        sortDescriptors: [
            NSSortDescriptor(
                keyPath: \MeetingRecord.createdAt,
                ascending: false
            )
        ],
        animation: .default
    )
    private var meetings: FetchedResults<MeetingRecord>

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                TextField(
                    "Masukkan meeting text disini",
                    text: $viewModel.meetingText
                )
                if viewModel.meetingSummary.isEmpty == false {
                    Text(viewModel.meetingSummary)
                }
                if viewModel.meetingText.isEmpty == false {
                    Text(viewModel.meetingText)
                }
                Button("Summarize & Save") {
                    Task {
                        await viewModel.startTextSummaryAndSave()
                    }
                }
                .buttonStyle(.borderedProminent)
                Text(viewModel.isRecording ? "Recording…" : "Idle")
                    .font(.headline)

                Button(viewModel.isRecording ? "Stop" : "Record") {
                    Task {
                        do {
                            if viewModel.isRecording {
                                viewModel.stopRecording()
                                showResult = true
                            } else {
                                try await viewModel.requestPermission()
                                try viewModel.startRecording()
                            }
                        } catch {
                            print(error.localizedDescription)
                        }
                    }
                }
                .buttonStyle(.borderedProminent)

                Button(
                    viewModel.isRecording
                        ? "Stop Transcribe" : "Record Transcribe"
                ) {
                    Task {
                        do {
                            if viewModel.isRecording {
                                viewModel.endAudioTranscribe()
                            } else {
                                try await viewModel.requestPermission()
                                viewModel.startAudioTranscribe()
                            }
                        } catch {
                            print(error.localizedDescription)
                        }
                    }
                }
                .buttonStyle(.borderedProminent)
                
                Divider()

                Text("Saved Meetings")
                    .font(.headline)

                List {
                    ForEach(meetings.prefix(5)) { meeting in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(meeting.title ?? "Untitled")
                                .font(.subheadline)
                                .bold()

                            if let summary = meeting.summary {
                                Text(summary)
                                    .font(.caption)
                                    .lineLimit(2)
                            }

                            Text(meeting.createdAt ?? Date.now, style: .date)
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .frame(height: 250)

                NavigationLink(
                    isActive: $showResult,
                    destination: {
                        if let url = viewModel.outputURL {
                            RecordingResultView(audioURL: url, context: context)
                        } else {
                            EmptyView()
                        }
                    },
                    label: {
                        EmptyView()
                    }
                )
            }
            .padding()
        }
    }
}

//#Preview {
//    HomeView()
//}

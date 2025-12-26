//
//  ContentView.swift
//  AIMeetingTranscriber
//
//  Created by Zikar Nurizky on 25/12/25.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewViewModel()
    @State private var showResult = false
    var meetingText: String = ""
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                TextField("Masukkan meeting text disini", text: $viewModel.meetingText)
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

                NavigationLink(
                    isActive: $showResult,
                    destination: {
                        if let url = viewModel.outputURL {
                            RecordingResultView(audioURL: url)
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

#Preview {
    HomeView()
}

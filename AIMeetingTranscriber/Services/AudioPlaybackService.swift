//
//  AudioPlaybackService.swift
//  AIMeetingTranscriber
//
//  Created by Zikar Nurizky on 25/12/25.
//

import AVFoundation
import Combine


// A class that is created buat bikin playback service. Jadi kita bisa play ulang hasil recording

final class AudioPlaybackService: ObservableObject {
    @Published var isPlaying = false // Published state biar tau current state dr class ini
    private var player: AVAudioPlayer?
    
    func load(url: URL) throws {
        // Ngambil file recording via URL
        player = try AVAudioPlayer(contentsOf: url) // Baca URL recording then simpan ke player
        player?.prepareToPlay() // preloads audio buffer
    }
    
    func play() {
        player?.play() // play the playback
        isPlaying = true // ganti observed state buat class ini
    }
    
    func stop() {
        player?.stop() //stop the playback
        isPlaying = false // ganti observed state buat class ini
    }
}

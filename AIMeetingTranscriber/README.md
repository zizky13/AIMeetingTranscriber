# AI Meeting Transcriber and Summarizer

## Description
An app that records your meeting session, then turn it into a transcribed text with summary and action points.

## App Flow
Record -> Save (.m4a) -> Transcribe -> Feed to LLM -> Summary with action points

## Architecture
- iOS: SwiftUI + MVVM
- Audio: AVFoundation
- AI: LLM (ChatGPT)
- Storage: CoreData

## Features
- Record
- Playback
- Transcribe
- Summary

//
//  AIMeetingTranscriberApp.swift
//  AIMeetingTranscriber
//
//  Created by Zikar Nurizky on 25/12/25.
//

import SwiftUI
internal import CoreData

@main
struct AIMeetingTranscriberApp: App {
    let persistanceController = PersistenceController.shared
    var body: some Scene {
        WindowGroup {
            HomeView(context: persistanceController.container.viewContext)
                .environment(\.managedObjectContext,
                              persistanceController.container.viewContext)
        }
    }
}

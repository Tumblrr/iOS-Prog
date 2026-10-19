//
//  Fish_Management_AppApp.swift
//  Fish Management App
//
//  Created by Nguyễn Hoàng Bảo Hân on 19/10/26.
//

import SwiftUI
import SwiftData

@main
struct Fish_Management_AppApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}

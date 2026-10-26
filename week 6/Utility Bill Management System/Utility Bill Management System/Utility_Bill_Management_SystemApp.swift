//
//  Utility_Bill_Management_SystemApp.swift
//  Utility Bill Management System
//
//  Created by Nguyễn Hoàng Bảo Hân on 26/10/26.
//

import SwiftUI
import SwiftData

@main
struct Utility_Bill_Management_SystemApp: App {
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

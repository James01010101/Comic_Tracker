//
//  Comic_TrackerApp.swift
//  Comic Tracker
//
//  Created by James Coldwell on 28/7/2024.
//

import SwiftUI
import SwiftData

@main
struct Comic_TrackerApp: App {
	@StateObject private var persistenceController = PersistenceController.shared


    var body: some Scene {
        WindowGroup {
            ContentView()
				.environment(\.modelContext, persistenceController.context)
        }
    }
}

/*
 OLD EXAMPLE CODE
 import SwiftUI
 import SwiftData

 @main
 struct Comic_TrackerApp: App {
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
 */

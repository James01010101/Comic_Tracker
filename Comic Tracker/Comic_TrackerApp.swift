//
//  Comic_TrackerApp.swift
//  Comic Tracker
//
//  Created by James Coldwell on 28/7/2024.
//

import SwiftUI
import SwiftData

/// Main function to start my program
@main
struct Comic_TrackerApp: App {
	/// Store the static instance of the ``PersistenceController``
	@StateObject private var persistenceController = PersistenceController.shared
	
	/// Creates the static instance of ``GlobalState``
	@StateObject private var globalState = GlobalState.shared
	
	var body: some Scene {
		WindowGroup {
			ContentView()
				.environment(\.modelContext, persistenceController.context)
		}
	}
}

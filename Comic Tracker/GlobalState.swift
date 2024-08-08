//
//  GlobalState.swift
//  Comic Tracker
//
//  Created by James Coldwell on 4/8/2024.
//

import SwiftUI

/// Stores any global variables and states that might be accessed from different views.
class GlobalState: ObservableObject {
	/// Static instance of the ``GlobalState``
	static let shared = GlobalState()
	
	// these are variable related to the views that i want to be global
	/// Used to display the saved data icon.
	/// - Values:
	///   - `nil`: Default save icon if data has changed and needs to be saved
	///   - `true`: Tick icon if successful save
	///   - `false`: Cross icon if failed save
	@Published var saveDataIcon: Bool?
	
	
	
	// part of the settings the user can change
	/// Automatically call the save function everytime data is changed.
	///
	/// This will write to a file every single time, can be better for normal usage.
	/// > Tip: If inputting a large number of elements at once it is better to turn this off, to reduce writing the whole database everytime.
	@Published var autoSave: Bool
	
	
	/// Initialise the default state of the ``GlobalState`` variables.
	init() {
		// global view settings
		// starts ticked because nothing has changed
		self.saveDataIcon = true
		
		// global settings
		self.autoSave = true
	}
}

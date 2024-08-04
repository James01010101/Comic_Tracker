//
//  GlobalState.swift
//  Comic Tracker
//
//  Created by James Coldwell on 4/8/2024.
//
// This is used for storing any global variables and states that i might want to access from different views
//

import SwiftUI

class GlobalState: ObservableObject {
	static let shared = GlobalState()
	
	// these are variable related to the views that i want to be global
	/// This is used to display the saved data icon. nil is default. true is a tick and false is a cross if saving failed
	@Published var saveDataIcon: Bool?
	
	
	
	// part of the settings the user can change
	/// Whether to automatically call the save function everytime a comic is added or deleted. This will write to a file every single time, can be better for normal usage but if inputting a large number of elements at once it is better to turn this off to reduce writing the whole database everytime,
	@Published var autoSave: Bool
	
	
	init() {
		// global view settings
		// starts ticked because nothing has changed
		self.saveDataIcon = true
		
		// global settings
		self.autoSave = true
	}
}

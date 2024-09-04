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
	
	// Debugging variables
	/// if i am running in preview mode or not, mainly so i dont actually do things like writing to disc
	@Published var runningInPreview: Bool
	
	
	// these are variable related to the views that i want to be global
	/// Used to display the saved data icon.
	/// - Values:
	///   - `nil`: Default save icon if data has changed and needs to be saved
	///   - `true`: Tick icon if successful save
	///   - `false`: Cross icon if failed save
	@Published var saveDataIcon: Bool?
	
	/// The max length a string can be to be displayed.
	///
	/// If the main string is longer than this then a shorted string is required
	/// The main string will still be used for all checks but the shortened string will be used to display
	@Published var maxDisplayedStringLength: UInt8 = 30
	
	/// Stores a dictionary of colliding series names to number of usages
	///
	/// On initial load of my series data, this is filled out and for every series it increases the number of usages.
	/// So i can search for a specific series name and know the exact number of series with this name
	///
	/// > Note: This is not persistant and is recalculated everytime the app loads the series file. But as it is O(n) it doesnt add any extra complexity
	@Published var seriesNamesUsages: [String: UInt8]
	
	
	// part of the settings the user can change
	/// Automatically call the save function everytime data is changed.
	///
	/// This will write to a file every single time, can be better for normal usage.
	/// > Tip: If inputting a large number of elements at once it is better to turn this off, to reduce writing the whole database everytime.
	@Published var autoSave: Bool
	
	
	
	
	// Hardcoded variables i want set that cant be changed
	/// This is a hardcoded list of colours to brands, so for instance Marvel comics have a red background when being listed
	@Published var brandRowColours: [String: Color];
	
	@Published var mainDisplayTextSize: CGFloat;
	@Published var mainDisplayTextColour: Color;
	
	
	/// Initialise the default state of the ``GlobalState`` variables.
	init() {
		// debug settings
		runningInPreview = false;
		
		
		// global view settings
		// starts ticked because nothing has changed
		self.saveDataIcon = true;
		
		// create the series dictionary
		self.seriesNamesUsages = [String: UInt8]();
		
		
		
		// global settings
		self.autoSave = true;
		
		
		
		// Hardcoded Variables
		self.brandRowColours = [
			"Marvel": Color.red,
			"Five Nights At Freddy's": Color.orange,
			"Invincible": Color.yellow,
			"The Walking Dead": Color.green,
			"Jujutsu Kaisen": Color.purple,
			"Star Wars": Color.blue,
		];
		
		self.mainDisplayTextSize = 18.0;
		self.mainDisplayTextColour = Color.black;
	}
	
	
	/// Used to reset the series names usages dict back to empty
	///
	/// Mainly used in the preview functions to reset it everytime it loads so multiple loads dont keep it around
	public func resetSeriesNamesUsages() {
		self.seriesNamesUsages = [String: UInt8]()
	}
	
	
	public func getBrandColor(brandName: String) -> Color {
		return self.brandRowColours[brandName] ?? Color.gray;
	}
}

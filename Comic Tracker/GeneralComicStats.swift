//
//  GeneralComicStats.swift
//  Comic Tracker
//
//  Created by James Coldwell on 29/7/2024.
//

import Foundation
import SwiftData


// This will contain any general values that i want to keep relating to Comics or events or series
@Model
class GeneralComicStats {
	/// This is the ID of the last book added, it will increment everytime you ask for it
	var readId: UInt32
	
	init(readId: UInt32) {
		self.readId = readId
	}
	
	
	/// Increment the read ID and return it. Used to give a new comic book a unique ID
	public func getNextReadId() -> UInt32 {
		// increment and return the new readId
		self.readId = self.readId + 1
		return self.readId
	}
}


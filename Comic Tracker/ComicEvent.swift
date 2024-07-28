//
//  ComicEvent.swift
//  Comic Tracker
//
//  Created by James Coldwell on 28/7/2024.
//

import Foundation
import SwiftData

/**
 Stores all necessary data for a comic event
 */
@Model
class ComicEvent {
	/// The full name of this event
	var event_name: String
	/// The total number of comic issues that have been read in this event (doesn't have to be in order)
	var issues_read: UInt16
	/// The total number of comic issues this event has
	var total_issues: UInt16
	/// The total number of pages read in all comic books in this event
	var pages_read: UInt16
	
	
	init(event_name: String, 
		 issues_read: UInt16,
		 total_issues: UInt16,
		 pages_read: UInt16) {
		
		self.event_name = event_name
		self.issues_read = issues_read
		self.total_issues = total_issues
		self.pages_read = pages_read
	}
}

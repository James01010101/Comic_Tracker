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
	var eventName: String
	/// The total number of comic issues that have been read in this event (doesn't have to be in order)
	var issuesRead: UInt16
	/// The total number of comic issues this event has
	var totalIssues: UInt16
	/// The total number of pages read in all comic books in this event
	var pagesRead: UInt16
	
	
	init(eventName: String,
		 issuesRead: UInt16,
		 totalIssues: UInt16,
		 pagesRead: UInt16) {
		
		self.eventName = eventName
		self.issuesRead = issuesRead
		self.totalIssues = totalIssues
		self.pagesRead = pagesRead
	}
}

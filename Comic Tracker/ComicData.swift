//
//  ComicData.swift
//  Comic Tracker
//
//  Created by James Coldwell on 28/7/2024.
//

import Foundation
import SwiftData

/**
 Stores all necessary data for an individual comic book and how it related to events and series
 */
@Model
class ComicData {
	/// This is the nth comic i have read
	var readId: UInt32
	/// The full title of the comic book
	var comicFullTitle: String
	/// The year the first issue was first published, not the year this current issue was published (used to help distinguish series with the same name)
	var yearFirstPublished: UInt16
	/// WIthin a series which issue is this
	var issueNumber: UInt16
	/// The total number of pages this comic has
	var totalPages: UInt16
	/// What event does this comic belong to
	var eventName: String
	/// Give the comic a purpose as to why it was read
	var purpose: String
	
	
	init(readId: UInt32,
		 comicFullTitle: String,
		 yearFirstPublished: UInt16,
		 issueNumber: UInt16,
		 totalPages: UInt16,
		 eventName: String,
		 purpose: String) {
		
		self.readId = readId
		self.comicFullTitle = comicFullTitle
		self.yearFirstPublished = yearFirstPublished
		self.issueNumber = issueNumber
		self.totalPages = totalPages
		self.eventName = eventName
		self.purpose = purpose
	}
}

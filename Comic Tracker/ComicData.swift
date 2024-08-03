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
	/// Brand eg (Marvel, Star Wars, FNAF)
	var brand: String
	/// The name of the full series (This is the main comic name. if multiple books in a series can have different names then they can be specified later)
	var seriesName: String
	/// (Optional. If left empty, defaults to seriesName) The name of this book if books in a series can have different names instead of issues
	/// eg normal: JJK #1, #2.
	/// Different names: Fasbear Frights: Into The Pit, Fasbear Frights: Fetch
	/// This allows you to specify different names for the individual books if is isnt just an issue number change. (Still use issue numbers)
	var individualComicName: String
	/// The year the first issue was first published, not the year this current issue was published (used to help distinguish series with the same name)
	var yearFirstPublished: UInt16
	/// WIthin a series which issue is this (Required even if using IndividualComicName)
	var issueNumber: UInt16
	/// The total number of pages this comic has
	var totalPages: UInt16
	/// What event does this comic belong to
	var eventName: String
	/// Give the comic a purpose as to why it was read
	var purpose: String
	
	
	init(readId: UInt32, 
		 brand: String,
		 seriesName: String,
		 individualComicName: String,
		 yearFirstPublished: UInt16,
		 issueNumber: UInt16,
		 totalPages: UInt16,
		 eventName: String,
		 purpose: String) {
		
		self.readId = readId
		self.brand = brand
		self.seriesName = seriesName
		self.individualComicName = individualComicName
		self.yearFirstPublished = yearFirstPublished
		self.issueNumber = issueNumber
		self.totalPages = totalPages
		self.eventName = eventName
		self.purpose = purpose
	}
}

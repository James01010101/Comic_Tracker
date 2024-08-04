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
class ComicData: Codable {
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
	/// The date this comic was read (Automatically filled in when a comic is added) Old comics will just be none because i dont have the exact date
	var dateRead: Date
	//var test: Int
	
	
	init(readId: UInt32,
		 brand: String,
		 seriesName: String,
		 individualComicName: String,
		 yearFirstPublished: UInt16,
		 issueNumber: UInt16,
		 totalPages: UInt16,
		 eventName: String,
		 purpose: String,
		 dateRead: Date) {
		
		self.readId = readId
		self.brand = brand
		self.seriesName = seriesName
		self.individualComicName = individualComicName
		self.yearFirstPublished = yearFirstPublished
		self.issueNumber = issueNumber
		self.totalPages = totalPages
		self.eventName = eventName
		self.purpose = purpose
		self.dateRead = dateRead
		//self.test = 0
	}
	
	// Conformance to Codable
	enum CodingKeys: String, CodingKey {
		case readId
		case brand
		case seriesName
		case individualComicName
		case yearFirstPublished
		case issueNumber
		case totalPages
		case eventName
		case purpose
		case dateRead
		//case test
	}
	
	required init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		readId = try container.decode(UInt32.self, forKey: .readId)
		brand = try container.decode(String.self, forKey: .brand)
		seriesName = try container.decode(String.self, forKey: .seriesName)
		individualComicName = try container.decode(String.self, forKey: .individualComicName)
		yearFirstPublished = try container.decode(UInt16.self, forKey: .yearFirstPublished)
		issueNumber = try container.decode(UInt16.self, forKey: .issueNumber)
		totalPages = try container.decode(UInt16.self, forKey: .totalPages)
		eventName = try container.decode(String.self, forKey: .eventName)
		purpose = try container.decode(String.self, forKey: .purpose)
		dateRead = try container.decode(Date.self, forKey: .dateRead)
		//test = try container.decode(Int.self, forKey: .test)
	}
	
	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(readId, forKey: .readId)
		try container.encode(brand, forKey: .brand)
		try container.encode(seriesName, forKey: .seriesName)
		try container.encode(individualComicName, forKey: .individualComicName)
		try container.encode(yearFirstPublished, forKey: .yearFirstPublished)
		try container.encode(issueNumber, forKey: .issueNumber)
		try container.encode(totalPages, forKey: .totalPages)
		try container.encode(eventName, forKey: .eventName)
		try container.encode(purpose, forKey: .purpose)
		try container.encode(dateRead, forKey: .dateRead)
		//try container.encode(test, forKey: .test)
	}
}

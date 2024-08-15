//
//  ComicData.swift
//  Comic Tracker
//
//  Created by James Coldwell on 28/7/2024.
//

import Foundation
import SwiftData

/// Stores all necessary data for an individual comic book and how it relates to events and series.
///
/// It must conform to `Codable` because this enables it to be converted to and from `JSON`, which is used for writing and reading from the backup files.
@Model
class ComicData: Codable {
	/// This is used as a static unique id for each comic.
	///
	/// Everytime I create a new comic it gets incremented and given to the new comic so they each get a unique id. This is also used to know the order that I read the comics.
	static var staticComicId: UInt32 = 0
	
	/// This is the n'th comic I have read, it is an id which mainly shows the order of comics I have read, but is also used to uniquely identify each comic.
	var comicId: UInt32
	
	/// Brand this comic is from, example: (Marvel, Star Wars, FNAF).
	var brandName: String
	/// The shorthand brand of the brand, example "TWD".
	var shortBrandName: String
	/// The prioties shorthand even if it isnt needed
	var prioritizeShortBrandName: Bool
	
	/// The name of the series this comic is part of.
	///
	/// This is the main comic's name. If multiple books in a series can have different names then they can be specified later in the ``individualComicName``.
	var seriesName: String
	/// The shorthand series name, example "TWD".
	var shortSeriesName: String
	/// The prioties shorthand even if it isnt needed
	var prioritizeShortSeriesName: Bool
	
	/// The name of this book if books in a series can have different names, instead of, or including, issues (Optional).
	///
	/// - Examples:
	///   - Normal case:
	///     - JJK #1
	///     - JJK #2
	///   - Different case: 
	///     - Fasbear Frights: Into The Pit
	///     - Fasbear Frights: Fetch
	///
	/// This allows you to specify different names for the individual books, if it isn't just an issue number change (Still use issue numbers).
	var comicName: String
	/// The shorthand comic name, example "TWD".
	var shortComicName: String
	/// The prioties shorthand even if it isnt needed
	var prioritizeShortComicName: Bool
	
	/// Year the first issue of this series was first published.
	/// 
	/// Used to help distinguish series with the same name, but that were released in different years.
	/// 
	/// > Important: Not the year this current issue was published.
	var yearFirstPublished: UInt16
	/// WIthin a series which issue is this.
	///
	/// Required even if using ``individualComicName``.
	var issueNumber: UInt16
	/// The total number of pages this comic has.
	var totalPages: UInt16
	/// What event does this comic belong to (Optional).
	var eventName: String
	/// Give the comic a purpose as to why it was read.
	///
	/// Did I read it for a specific character or group of event?
	var purpose: String
	/// The date this comic was read.
	///
	/// Automatically filled in when a comic is added, but can be manually set.
	var dateRead: Date?
	
	
	/// Creates a new ``ComicData``.
	///
	/// This will also give it it's new unique id.
	init(brandName: String,
		 shortBrandName: String,
		 prioritizeShortBrandName: Bool,
		 
		 seriesName: String,
		 shortSeriesName: String,
		 prioritizeShortSeriesName: Bool,
		 
		 comicName: String,
		 shortComicName: String,
		 prioritizeShortComicName: Bool,
		 
		 yearFirstPublished: UInt16,
		 issueNumber: UInt16,
		 totalPages: UInt16,
		 eventName: String,
		 purpose: String,
		 dateRead: Date?
	) {
		
		ComicData.staticComicId += 1
		self.comicId = ComicData.staticComicId
		
		self.brandName = brandName
		self.shortBrandName = shortBrandName
		self.prioritizeShortBrandName = prioritizeShortBrandName
		
		self.seriesName = seriesName
		self.shortSeriesName = shortSeriesName
		self.prioritizeShortSeriesName = prioritizeShortSeriesName
		
		self.comicName = comicName
		self.shortComicName = shortComicName
		self.prioritizeShortComicName = prioritizeShortComicName
		
		self.yearFirstPublished = yearFirstPublished
		self.issueNumber = issueNumber
		self.totalPages = totalPages
		self.eventName = eventName
		self.purpose = purpose
		self.dateRead = dateRead
	}
	
	/// Conformance to Codable, a list of enums representing the variables I'm storing.
	enum CodingKeys: String, CodingKey {
		case comicId
		
		case brandName
		case shortBrandName
		case prioritizeShortBrandName
		
		case seriesName
		case shortSeriesName
		case prioritizeShortSeriesName
		
		case comicName
		case shortComicName
		case prioritizeShortComicName
		
		case yearFirstPublished
		case issueNumber
		case totalPages
		case eventName
		case purpose
		case dateRead
	}
	
	/// Conformance to Codable,  a decoder function to take a `JSON` decoder object read in from my backup file and create a new ``ComicData`` from it.
	/// - Parameter decoder: Takes a ``Decoder`` and creates a new ``ComicData`` from it.
	required init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		
		// The id is saved in the files to keep the order so i need to update the static id everytime so if i add a new comic it is at the right value
		let tmpComicId = try container.decode(UInt32.self, forKey: .comicId)
		comicId = tmpComicId
		ComicData.staticComicId = tmpComicId
		
		comicId = try container.decode(UInt32.self, forKey: .comicId)
		
		brandName = try container.decode(String.self, forKey: .brandName)
		shortBrandName = try container.decode(String.self, forKey: .shortBrandName)
		prioritizeShortBrandName = try container.decode(Bool.self, forKey: .prioritizeShortBrandName)
		
		seriesName = try container.decode(String.self, forKey: .seriesName)
		shortSeriesName = try container.decode(String.self, forKey: .shortSeriesName)
		prioritizeShortSeriesName = try container.decode(Bool.self, forKey: .prioritizeShortSeriesName)
		
		comicName = try container.decode(String.self, forKey: .comicName)
		shortComicName = try container.decode(String.self, forKey: .shortComicName)
		prioritizeShortComicName = try container.decode(Bool.self, forKey: .prioritizeShortComicName)
		
		yearFirstPublished = try container.decode(UInt16.self, forKey: .yearFirstPublished)
		issueNumber = try container.decode(UInt16.self, forKey: .issueNumber)
		totalPages = try container.decode(UInt16.self, forKey: .totalPages)
		eventName = try container.decode(String.self, forKey: .eventName)
		purpose = try container.decode(String.self, forKey: .purpose)
		dateRead = try container.decode(Date?.self, forKey: .dateRead)
	}
	
	/// Conformance to Codable,  a encoder function to encode my ``ComicData`` into `JSON` to be written to a file.
	/// - Parameter encoder: Takes an ``Encoder`` and encoders `this` into it.
	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		
		try container.encode(comicId, forKey: .comicId)
		
		try container.encode(brandName, forKey: .brandName)
		try container.encode(shortBrandName, forKey: .shortBrandName)
		try container.encode(prioritizeShortBrandName, forKey: .prioritizeShortBrandName)
		
		try container.encode(seriesName, forKey: .seriesName)
		try container.encode(shortSeriesName, forKey: .shortSeriesName)
		try container.encode(prioritizeShortSeriesName, forKey: .prioritizeShortSeriesName)
		
		try container.encode(comicName, forKey: .comicName)
		try container.encode(shortComicName, forKey: .shortComicName)
		try container.encode(prioritizeShortComicName, forKey: .prioritizeShortComicName)
		
		try container.encode(yearFirstPublished, forKey: .yearFirstPublished)
		try container.encode(issueNumber, forKey: .issueNumber)
		try container.encode(totalPages, forKey: .totalPages)
		try container.encode(eventName, forKey: .eventName)
		try container.encode(purpose, forKey: .purpose)
		try container.encode(dateRead, forKey: .dateRead)
	}
}

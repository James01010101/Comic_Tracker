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
class ComicData: Codable, Identifiable {
	/// This is used as a static unique id for each comic.
	///
	/// Everytime I create a new comic it gets incremented and given to the new comic so they each get a unique id. This is also used to know the order that I read the comics.
	static var staticComicId: UInt32 = 0;
	
	/// This is the n'th comic I have read, it is an id which mainly shows the order of comics I have read, but is also used to uniquely identify each comic.
	var comicId: UInt32 = 0;
	/// Use comicId to fulfill the Identifiable requirement
	var id: UInt32 { comicId };
	
	/// Brand this comic is from, example: (Marvel, Star Wars, FNAF).
	var brandName: String = "";
	/// The shorthand brand of the brand, example "TWD".
	var shortBrandName: String = "";
	/// The prioties shorthand even if it isnt needed
	var prioritizeShortBrandName: Bool = false;
	
	/// The name of the series this comic is part of.
	///
	/// This is the main comic's name. If multiple books in a series can have different names then they can be specified later in the ``individualComicName``.
	var seriesName: String = "";
	/// The shorthand series name, example "TWD".
	var shortSeriesName: String = "";
	/// The prioties shorthand even if it isnt needed
	var prioritizeShortSeriesName: Bool = false;
	
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
	var comicName: String = "";
	/// The shorthand comic name, example "TWD".
	var shortComicName: String = "";
	/// The prioties shorthand even if it isnt needed
	var prioritizeShortComicName: Bool = false;
	
	/// Year the first issue of this series was first published.
	///
	/// Used to help distinguish series with the same name, but that were released in different years.
	///
	/// > Important: Not the year this current issue was published.
	var yearFirstPublished: UInt16 = 0;
	/// WIthin a series which issue is this.
	///
	/// Required even if using ``individualComicName``.
	var issueNumber: UInt16 = 0;
	/// The total number of pages this comic has.
	var totalPages: UInt16 = 0;
	/// What event does this comic belong to (Optional).
	var eventName: String = "";
	/// Give the comic a purpose as to why it was read.
	///
	/// Did I read it for a specific character or group of event?
	var purpose: String = "";
	/// The date this comic was read.
	///
	/// Automatically filled in when a comic is added, but can be manually set.
	var dateRead: Date? = nil;
	
	/// This is a link to the marvel ultimate page for this comic.
	///
	/// Mainly used in the event list to be able to easily find a comic to read
	var marvelUltimateLink: String = "";
	
	/// Enum to store wether ive read this comic or not
	var comicRead: ComicReadEnum = ComicReadEnum.NotRead;
	
	
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
		 dateRead: Date?,
		 
		 marvelUltimateLink: String,
		 comicRead: ComicReadEnum
	) {
		
		ComicData.staticComicId += 1
		self.comicId = ComicData.staticComicId
		
		print("Loading Comic Data, Static id: " + String(ComicData.staticComicId));
		
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
		
		self.marvelUltimateLink = marvelUltimateLink
		self.comicRead = comicRead
	}
	
	/// Conformance to Codable, a list of enums representing the variables I'm storing.
	/// giving them shorter names so the filesize is smaller because its not using the full variable names every time
	enum CodingKeys: String, CodingKey {
		case comicId = "id"
		
		case brandName = "brand"
		case shortBrandName = "sBrand"
		case prioritizeShortBrandName = "psBrand"
		
		case seriesName = "series"
		case shortSeriesName = "sSeries"
		case prioritizeShortSeriesName = "psSeries"
		
		case comicName = "comic"
		case shortComicName = "sComic"
		case prioritizeShortComicName = "psComic"
		
		case yearFirstPublished = "year"
		case issueNumber = "issue"
		case totalPages = "pages"
		case eventName = "event"
		case purpose = "purpose"
		case dateRead = "date"
		
		case marvelUltimateLink = "link"
		case comicRead = "read"
	}
	
	/// Conformance to Codable,  a decoder function to take a `JSON` decoder object read in from my backup file and create a new ``ComicData`` from it.
	/// - Parameter decoder: Takes a ``Decoder`` and creates a new ``ComicData`` from it.
	required init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		
		// The id is saved in the files to keep the order so i need to update the static id everytime so if i add a new comic it is at the right value
		let tmpComicId = try container.decode(UInt32.self, forKey: .comicId)
		comicId = tmpComicId
				
		brandName = try container.decode(String.self, forKey: .brandName)
		shortBrandName = try container.decodeIfPresent(String.self, forKey: .shortBrandName) ?? ""
		let prioritizeShortBrandNameInt = try container.decodeIfPresent(Int.self, forKey: .prioritizeShortBrandName) ?? 0 // saved as a 1 or 0 instead of true / false, so i need to decode that back into boolean
		prioritizeShortBrandName = prioritizeShortBrandNameInt == 1
		
		seriesName = try container.decode(String.self, forKey: .seriesName)
		shortSeriesName = try container.decodeIfPresent(String.self, forKey: .shortSeriesName) ?? ""
		let prioritizeShortSeriesNameInt = try container.decodeIfPresent(Int.self, forKey: .prioritizeShortSeriesName) ?? 0
		prioritizeShortSeriesName = prioritizeShortSeriesNameInt == 1
		
		comicName = try container.decodeIfPresent(String.self, forKey: .comicName)  ?? ""
		shortComicName = try container.decodeIfPresent(String.self, forKey: .shortComicName) ?? ""
		prioritizeShortComicName = try container.decodeIfPresent(Bool.self, forKey: .prioritizeShortComicName) ?? false
		let prioritizeShortComicNameInt = try container.decodeIfPresent(Int.self, forKey: .prioritizeShortComicName) ?? 0
		prioritizeShortComicName = prioritizeShortComicNameInt == 1
		
		yearFirstPublished = try container.decode(UInt16.self, forKey: .yearFirstPublished)
		issueNumber = try container.decode(UInt16.self, forKey: .issueNumber)
		totalPages = try container.decode(UInt16.self, forKey: .totalPages)
		eventName = try container.decodeIfPresent(String.self, forKey: .eventName) ?? ""
		purpose = try container.decodeIfPresent(String.self, forKey: .purpose) ?? ""
		dateRead = try container.decodeIfPresent(Date?.self, forKey: .dateRead) ?? nil
		
		marvelUltimateLink = try container.decodeIfPresent(String.self, forKey: .marvelUltimateLink) ?? ""
		comicRead = try container.decode(ComicReadEnum.self, forKey: .comicRead)
	}
	
	/// Conformance to Codable,  a encoder function to encode my ``ComicData`` into `JSON` to be written to a file.
	///
	/// For some bariables if they can be empty strings or null and they are i just wont save that to disc and when reading it in later if it didnt exist on file then ill load it in as a default value respectively.
	/// - Parameter encoder: Takes an ``Encoder`` and encoders `this` into it.
	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		
		try container.encode(comicId, forKey: .comicId)
		
		try container.encode(brandName, forKey: .brandName)
		if (!shortBrandName.isEmpty) {
			try container.encode(shortBrandName, forKey: .shortBrandName)
			try container.encode(prioritizeShortBrandName ? 1 : 0, forKey: .prioritizeShortBrandName)
		}
		
		try container.encode(seriesName, forKey: .seriesName)
		if (!shortSeriesName.isEmpty) {
			try container.encode(shortSeriesName, forKey: .shortSeriesName)
			try container.encode(prioritizeShortSeriesName ? 1 : 0, forKey: .prioritizeShortSeriesName)
		}
		
		if (!comicName.isEmpty) { try container.encode(comicName, forKey: .comicName) }
		if (!shortComicName.isEmpty) {
			try container.encode(shortComicName, forKey: .shortComicName)
			try container.encode(prioritizeShortComicName ? 1 : 0, forKey: .prioritizeShortComicName)
		}
		
		try container.encode(yearFirstPublished, forKey: .yearFirstPublished)
		try container.encode(issueNumber, forKey: .issueNumber)
		try container.encode(totalPages, forKey: .totalPages)
		if (!eventName.isEmpty) { try container.encode(eventName, forKey: .eventName) }
		if (!purpose.isEmpty) { try container.encode(purpose, forKey: .purpose) }
		if (dateRead != nil) { try container.encode(dateRead, forKey: .dateRead) }
		
		if (!marvelUltimateLink.isEmpty) { try container.encode(marvelUltimateLink, forKey: .marvelUltimateLink) }
		try container.encode(comicRead, forKey: .comicRead)
	}
}

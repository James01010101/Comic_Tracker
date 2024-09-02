//
//  ComicSeries.swift
//  Comic Tracker
//
//  Created by James Coldwell on 28/7/2024.
//

import Foundation
import SwiftData

/// Stores all necessary data for an individual comic series.
///
/// It must conform to `Codable` because this enables it to be converted to and from `JSON`, which is used for writing and reading from the backup files.
@Model
class ComicSeries: Codable, Identifiable {
	/// This is used as a static unique id
	///
	/// Everytime I create a new series it gets incremented and given to that series so they each get a unique id. It is also used to know the order of series I have read
	static var staticSeriesId: UInt32 = 0
	
	/// Unique id for this series
	///
	/// > Note: Mainly used internally, most likely won't be shown to the user.
	var seriesId: UInt32
	/// Use seriesId to fulfill the Identifiable requirement
	var id: UInt32 { seriesId }
	
	/// Brand of the series
	var brandName: String
	/// The shorthand brand of the brand, example "TWD".
	var shortBrandName: String
	/// The prioties shorthand even if it isnt needed
	var prioritizeShortBrandName: Bool
	
	/// The title of this series.
	var seriesName: String
	/// The shorthand brand of the series name, example "TWD".
	var shortSeriesName: String
	/// The prioties shorthand even if it isnt needed
	var prioritizeShortSeriesName: Bool
	
	/// The year the first comic book in this series was first published
	///
	/// Used to help distinguish series with the same name.
	var yearFirstPublished: UInt16
	/// Total number of comic book issues read in this series.
	///
	/// > Note: I don't have to have read the comics in this series in order.
	var issuesRead: UInt16
	/// Total number of comic book issues in this series.
	var totalIssues: UInt16
	/// The total number of pages read in all comic books in this series.
	var pagesRead: UInt16
	
	// theses are variables of the most recent comic added so i can easily add a continuing series from these stats
	/// Recent comics issue
	var recentComicIssueNumber: UInt16
	/// Recent comics total pages
	var recentComicTotalPages: UInt16
	/// Recent comics event name
	var recentComicEventName: String
	/// Recent comics purpose
	var recentComicPurpose: String
	
	
	
	/// Create a new ``ComicSeries``
	///
	/// This will also give it it's new unique id.
	init(brandName: String,
		 shortBrandName: String,
		 prioritizeShortBrandName: Bool,
		 
		 seriesName: String,
		 shortSeriesName: String,
		 prioritizeShortSeriesName: Bool,
		 
		 yearFirstPublished: UInt16,
		 issuesRead: UInt16,
		 totalIssues: UInt16,
		 pagesRead: UInt16,
		 recentComicIssueNumber: UInt16,
		 recentComicTotalPages: UInt16,
		 recentComicEventName: String,
		 recentComicPurpose: String
	) {
		
		ComicSeries.staticSeriesId += 1
		self.seriesId = ComicSeries.staticSeriesId
		
		self.brandName = brandName
		self.shortBrandName = shortBrandName
		self.prioritizeShortBrandName = prioritizeShortBrandName
		
		self.seriesName = seriesName
		self.shortSeriesName = shortSeriesName
		self.prioritizeShortSeriesName = prioritizeShortSeriesName
		
		self.yearFirstPublished = yearFirstPublished
		self.issuesRead = issuesRead
		self.totalIssues = totalIssues
		self.pagesRead = pagesRead
		
		self.recentComicIssueNumber = recentComicIssueNumber
		self.recentComicTotalPages = recentComicTotalPages
		self.recentComicEventName = recentComicEventName
		self.recentComicPurpose = recentComicPurpose
	}
	
	
	
	/// Updated the most recent comic stats of this series with a newly added comic
	/// - Parameter comic: Takes a ``ComicData`` containing the most recent comic added to this series
	func updateRecentComicStats(comic: ComicData) {
		self.recentComicIssueNumber = comic.issueNumber
		self.recentComicTotalPages = comic.totalPages
		self.recentComicEventName = comic.eventName
		self.recentComicPurpose = comic.purpose
	}
	
	
	
	/// Conformance to Codable, a list of enums representing the variables I'm storing.
	enum CodingKeys: String, CodingKey {
		case seriesId = "id"
		
		case brandName = "brand"
		case shortBrandName = "sBrand"
		case prioritizeShortBrandName = "psBrand"
		
		case seriesTitle = "series"
		case shortSeriesName = "sSeries"
		case prioritizeShortSeriesName = "psSeries"
		
		case yearFirstPublished = "year"
		case issuesRead = "issuesRead"
		case totalIssues = "totalIssues"
		case pagesRead = "pages"
		case recentComicIssueNumber = "rIssue"
		case recentComicTotalPages = "rTotalPages"
		case recentComicEventName = "rEvent"
		case recentComicPurpose = "rPurpose"
	}
	
	/// Conformance to Codable,  a decoder function to take a `JSON` decoder object read in from my backup file and create a new ``ComicSeries`` from it.
	/// - Parameter decoder: Takes a ``Decoder`` and creates a new ``ComicSeries`` from it.
	required init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		
		// The id is saved in the files to keep the order so i need to update the static id everytime so if i add a new series it is at the right value
		let tmpSeriesId = try container.decode(UInt32.self, forKey: .seriesId)
		seriesId = tmpSeriesId
		ComicSeries.staticSeriesId = tmpSeriesId
		
		brandName = try container.decode(String.self, forKey: .brandName)
		shortBrandName = try container.decodeIfPresent(String.self, forKey: .shortBrandName) ?? ""
		let prioritizeShortBrandNameInt = try container.decodeIfPresent(Int.self, forKey: .prioritizeShortBrandName) ?? 0 // saved as a 1 or 0 instead of true / false, so i need to decode that back into boolean
		prioritizeShortBrandName = prioritizeShortBrandNameInt == 1
		
		seriesName = try container.decode(String.self, forKey: .seriesTitle)
		shortSeriesName = try container.decodeIfPresent(String.self, forKey: .shortSeriesName) ?? ""
		let prioritizeShortSeriesNameInt = try container.decodeIfPresent(Int.self, forKey: .prioritizeShortSeriesName) ?? 0
		prioritizeShortSeriesName = prioritizeShortSeriesNameInt == 1
		
		yearFirstPublished = try container.decode(UInt16.self, forKey: .yearFirstPublished)
		issuesRead = try container.decode(UInt16.self, forKey: .issuesRead)
		totalIssues = try container.decodeIfPresent(UInt16.self, forKey: .totalIssues) ?? 0
		pagesRead = try container.decode(UInt16.self, forKey: .pagesRead)
		
		// recent comic stats
		recentComicIssueNumber = try container.decode(UInt16.self, forKey: .recentComicIssueNumber)
		recentComicTotalPages = try container.decode(UInt16.self, forKey: .recentComicTotalPages)
		recentComicEventName = try container.decode(String.self, forKey: .recentComicEventName)
		recentComicPurpose = try container.decode(String.self, forKey: .recentComicPurpose)
	}
	
	/// Conformance to Codable,  a encoder function to encode my ``ComicSeries`` into `JSON` to be written to a file.
	/// - Parameter encoder: Takes an ``Encoder`` and encoders `this` into it.
	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		
		try container.encode(seriesId, forKey: .seriesId)
		
		try container.encode(brandName, forKey: .brandName)
		if (!shortBrandName.isEmpty) {
			try container.encode(shortBrandName, forKey: .shortBrandName)
			try container.encode(prioritizeShortBrandName ? 1 : 0, forKey: .prioritizeShortBrandName)
		}
		
		try container.encode(seriesName, forKey: .seriesTitle)
		if (!shortSeriesName.isEmpty) {
			try container.encode(shortSeriesName, forKey: .shortSeriesName)
			try container.encode(prioritizeShortSeriesName ? 1 : 0, forKey: .prioritizeShortSeriesName)
		}
		
		try container.encode(yearFirstPublished, forKey: .yearFirstPublished)
		try container.encode(issuesRead, forKey: .issuesRead)
		if (totalIssues != 0) {
			try container.encode(totalIssues, forKey: .totalIssues)
		}
		try container.encode(pagesRead, forKey: .pagesRead)
		
		// recent comic stats
		try container.encode(recentComicIssueNumber, forKey: .recentComicIssueNumber)
		try container.encode(recentComicTotalPages, forKey: .recentComicTotalPages)
		try container.encode(recentComicEventName, forKey: .recentComicEventName)
		try container.encode(recentComicPurpose, forKey: .recentComicPurpose)
	}
}

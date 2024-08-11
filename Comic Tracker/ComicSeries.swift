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
class ComicSeries: Codable {
	/// This is used as a static unique id
	///
	/// Everytime I create a new series it gets incremented and given to that series so they each get a unique id. It is also used to know the order of series I have read
	static var staticSeriesId: UInt32 = 0
	
	/// Unique id for this series
	///
	/// > Note: Mainly used internally, most likely won't be shown to the user.
	var seriesId: UInt32
	/// Brand of the series
	var seriesBrand: String
	/// The title of this series.
	var seriesTitle: String
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
	init(seriesBrand: String,
		 seriesTitle: String,
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
		self.seriesBrand = seriesBrand
		self.seriesTitle = seriesTitle
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
		case seriesId
		case seriesBrand
		case seriesTitle
		case yearFirstPublished
		case issuesRead
		case totalIssues
		case pagesRead
		case recentComicIssueNumber
		case recentComicTotalPages
		case recentComicEventName
		case recentComicPurpose
	}
	
	/// Conformance to Codable,  a decoder function to take a `JSON` decoder object read in from my backup file and create a new ``ComicSeries`` from it.
	/// - Parameter decoder: Takes a ``Decoder`` and creates a new ``ComicSeries`` from it.
	required init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		
		// The id is saved in the files to keep the order so i need to update the static id everytime so if i add a new series it is at the right value
		let tmpSeriesId = try container.decode(UInt32.self, forKey: .seriesId)
		seriesId = tmpSeriesId
		ComicSeries.staticSeriesId = tmpSeriesId
		
		seriesBrand = try container.decode(String.self, forKey: .seriesBrand)
		seriesTitle = try container.decode(String.self, forKey: .seriesTitle)
		yearFirstPublished = try container.decode(UInt16.self, forKey: .yearFirstPublished)
		issuesRead = try container.decode(UInt16.self, forKey: .issuesRead)
		totalIssues = try container.decode(UInt16.self, forKey: .totalIssues)
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
		try container.encode(seriesBrand, forKey: .seriesBrand)
		try container.encode(seriesTitle, forKey: .seriesTitle)
		try container.encode(yearFirstPublished, forKey: .yearFirstPublished)
		try container.encode(issuesRead, forKey: .issuesRead)
		try container.encode(totalIssues, forKey: .totalIssues)
		try container.encode(pagesRead, forKey: .pagesRead)
		
		// recent comic stats
		try container.encode(recentComicIssueNumber, forKey: .recentComicIssueNumber)
		try container.encode(recentComicTotalPages, forKey: .recentComicTotalPages)
		try container.encode(recentComicEventName, forKey: .recentComicEventName)
		try container.encode(recentComicPurpose, forKey: .recentComicPurpose)
	}
}

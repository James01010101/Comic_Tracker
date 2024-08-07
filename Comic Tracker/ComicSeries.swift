//
//  ComicSeries.swift
//  Comic Tracker
//
//  Created by James Coldwell on 28/7/2024.
//

import Foundation
import SwiftData

/**
 Stores all necessary data for a comic series
 */
@Model
class ComicSeries: Codable {
	/// this is used as a static id, so everytime i create a new series it gets incremented and given to that comic so they each get a unique id
	static var staticSeriesId: UInt32 = 0
	
	/// unique id for this series, mainly used internally, most likely wont be shown to the user
	var seriesId: UInt32
	/// The title of this series
	var seriesTitle: String
	/// The year the first comic book in this series was first published (used to help distinguish series with the same name)
	var yearFirstPublished: UInt16
	/// Total number of comic book issues read in this series
	var issuesRead: UInt16
	/// Total number of comic book issues in this series
	var totalIssues: UInt16
	/// The total number of pages read in all comic books in this series
	var pagesRead: UInt16
	
	
	init(seriesTitle: String,
		 yearFirstPublished: UInt16,
		 issuesRead: UInt16,
		 totalIssues: UInt16,
		 pagesRead: UInt16) {
		
		ComicSeries.staticSeriesId += 1
		self.seriesId = ComicSeries.staticSeriesId
		self.seriesTitle = seriesTitle
		self.yearFirstPublished = yearFirstPublished
		self.issuesRead = issuesRead
		self.totalIssues = totalIssues
		self.pagesRead = pagesRead
	}
	
	// needed to be able to encode this as json
	enum CodingKeys: String, CodingKey {
		case seriesId
		case seriesTitle
		case yearFirstPublished
		case issuesRead
		case totalIssues
		case pagesRead
	}
	
	required init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		
		// the id is saved in the files to keep the order so i need to update the static id everytime so if i add a new series it is at the right value
		let tmpSeriesId = try container.decode(UInt32.self, forKey: .seriesId)
		seriesId = tmpSeriesId
		ComicSeries.staticSeriesId = tmpSeriesId
		
		seriesTitle = try container.decode(String.self, forKey: .seriesTitle)
		yearFirstPublished = try container.decode(UInt16.self, forKey: .yearFirstPublished)
		issuesRead = try container.decode(UInt16.self, forKey: .issuesRead)
		totalIssues = try container.decode(UInt16.self, forKey: .totalIssues)
		pagesRead = try container.decode(UInt16.self, forKey: .pagesRead)
	}
	
	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		
		try container.encode(seriesId, forKey: .seriesId)
		try container.encode(seriesTitle, forKey: .seriesTitle)
		try container.encode(yearFirstPublished, forKey: .yearFirstPublished)
		try container.encode(issuesRead, forKey: .issuesRead)
		try container.encode(totalIssues, forKey: .totalIssues)
		try container.encode(pagesRead, forKey: .pagesRead)
	}
}

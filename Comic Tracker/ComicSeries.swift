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
class ComicSeries {
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
		
		self.seriesTitle = seriesTitle
		self.yearFirstPublished = yearFirstPublished
		self.issuesRead = issuesRead
		self.totalIssues = totalIssues
		self.pagesRead = pagesRead
	}
}

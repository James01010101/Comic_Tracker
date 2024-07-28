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
	var series_title: String
	/// The year the first comic book in this series was first published (used to help distinguish series with the same name)
	var year_first_published: UInt16
	/// Total number of comic book issues read in this series
	var issues_read: UInt16
	/// Total number of comic book issues in this series
	var total_issues: UInt16
	/// The total number of pages read in all comic books in this series
	var pages_read: UInt16
	
	
	init(series_title: String, 
		 year_first_published: UInt16,
		 issues_read: UInt16,
		 total_issues: UInt16,
		 pages_read: UInt16) {
		
		self.series_title = series_title
		self.year_first_published = year_first_published
		self.issues_read = issues_read
		self.total_issues = total_issues
		self.pages_read = pages_read
	}
}

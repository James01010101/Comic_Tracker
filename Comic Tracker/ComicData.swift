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
	var read_id: UInt32
	/// The full title of the comic book
	var comic_full_title: String
	/// The year the first issue was first published, not the year this current issue was published (used to help distinguish series with the same name)
	var year_first_published: UInt16
	/// WIthin a series which issue is this
	var issue_num: UInt16
	/// The total number of pages this comic has
	var total_pages: UInt16
	/// What event does this comic belong to
	var event_name: String
	/// Give the comic a purpose as to why it was read
	var purpose: String
	
	
	init(read_id: UInt32,
		 comic_full_title: String,
		 year_first_published: UInt16,
		 issue_num: UInt16,
		 total_pages: UInt16,
		 event_name: String,
		 purpose: String) {
		
		self.read_id = read_id
		self.comic_full_title = comic_full_title
		self.year_first_published = year_first_published
		self.issue_num = issue_num
		self.total_pages = total_pages
		self.event_name = event_name
		self.purpose = purpose
	}
}

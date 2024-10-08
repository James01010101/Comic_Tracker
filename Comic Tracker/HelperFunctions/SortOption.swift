//
//  Sort.swift
//  Comic Tracker
//
//  Created by James Coldwell on 5/10/2024.
//
// This file is my sort struct and functions to sort each data structure depending on its enum
import Foundation
import SwiftData


/// How i sort my lists of values
///
/// This is generic for each data structure
enum SortOption : String, CaseIterable, Identifiable {
	
	// sort by the read/series/event id
	case id = "ID"
	
	// Mainly for series and events sort by the total pages read
	case pagesRead = "Pages Read"
	
	// For series and events sort by the total number of issues read
	case issuesRead = "Issues Read"
	
	
	var id: String { self.rawValue }
}

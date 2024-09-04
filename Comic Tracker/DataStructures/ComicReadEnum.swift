//
//  ComicReadEnum.swift
//  Comic Tracker
//
//  Created by James Coldwell on 20/8/2024.
//

import Foundation
import SwiftData

/// Enum to store if ive read a comic or not
///
/// This is used in the comic events to be able to store event lists of comics but to label them as NotRead so i know i havent read them yet
///
/// Read: if ive read the comic
/// Skipped: if im not reading it or i cant find it
/// NotRead: if i havent read it yet
///
/// Giving them the String class to be able to easily store a displayable version of the enum vlaues
/// CaseIterable allows views to easily get a list of the elements in the enum for use in menus
/// Identifiable is used ro give an id to each object for unique id in a list
enum ComicReadEnum : String, Codable, CaseIterable, Identifiable {
	case Read = "Read"
	case Skipped = "Skipped"
	case NotRead = "Not Read"
	
	var id: String { self.rawValue }
}

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
enum ComicReadEnum : Codable {
	case Read
	case Skipped
	case NotRead
}

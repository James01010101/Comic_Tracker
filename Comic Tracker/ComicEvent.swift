//
//  ComicEvent.swift
//  Comic Tracker
//
//  Created by James Coldwell on 28/7/2024.
//

import Foundation
import SwiftData

/// Stores all necessary data for a comic book event.
///
/// It must conform to `Codable` because this enables it to be converted to and from `JSON`, which is used for writing and reading from the backup files.
@Model
class ComicEvent: Codable, Identifiable {
	/// This is used as a static unique id for each event.
	///
	/// Everytime I create a new event it gets incremented and given to the new event so they each get a unique id. This is also used to know the order that I read the events.
	static var staticEventId: UInt32 = 0
	
	/// Unique id for this event.
	///
	/// > Note: Mainly used internally, most likely wont be shown to the user.
	var eventId: UInt32
	/// Use eventId to fulfill the Identifiable requirement
	var id: UInt32 { eventId }
	
	/// The brand this event is part of eg Marvel
	var eventBrand: String
	/// The full name of this event.
	var eventName: String
	/// The total number of comic issues that have been read in this event.
	/// > Note: I don't have to have read the comics in this event in order.
	var issuesRead: UInt16
	/// The total number of comic issues in this event.
	var totalIssues: UInt16
	/// The total number of pages read in all comic books in this event.
	var pagesRead: UInt16
	
	

	/// Creates a new ``ComicEvent``.
	///
	/// This will also give it it's new unique id.
	init(eventBrand: String,
		 eventName: String,
		 issuesRead: UInt16,
		 totalIssues: UInt16,
		 pagesRead: UInt16) {
		
		ComicEvent.staticEventId += 1
		self.eventId = ComicEvent.staticEventId
		self.eventBrand = eventBrand
		self.eventName = eventName
		self.issuesRead = issuesRead
		self.totalIssues = totalIssues
		self.pagesRead = pagesRead
	}
	
	/// Conformance to Codable, a list of enums representing the variables I'm storing.
	enum CodingKeys: String, CodingKey {
		case eventId
		case eventBrand
		case eventName
		case issuesRead
		case totalIssues
		case pagesRead
	}
	
	/// Conformance to Codable,  a decoder function to take a `JSON` decoder object read in from my backup file and create a new ``ComicEvent`` from it.
	/// - Parameter decoder: Takes a ``Decoder`` and creates a new ``ComicEvent`` from it.
	required init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		
		// the id is saved in the files to keep the order so i need to update the static id everytime so if i add a new event it is at the right value
		let tmpEventId = try container.decode(UInt32.self, forKey: .eventId)
		eventId = tmpEventId
		ComicEvent.staticEventId = tmpEventId
		
		eventBrand = try container.decode(String.self, forKey: .eventBrand)
		eventName = try container.decode(String.self, forKey: .eventName)
		issuesRead = try container.decode(UInt16.self, forKey: .issuesRead)
		totalIssues = try container.decode(UInt16.self, forKey: .totalIssues)
		pagesRead = try container.decode(UInt16.self, forKey: .pagesRead)
	}
	
	/// Conformance to Codable,  a encoder function to encode my ``ComicEvent`` into `JSON` to be written to a file.
	/// - Parameter encoder: Takes an ``Encoder`` and encoders `this` into it.
	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		
		try container.encode(eventId, forKey: .eventId)
		try container.encode(eventBrand, forKey: .eventBrand)
		try container.encode(eventName, forKey: .eventName)
		try container.encode(issuesRead, forKey: .issuesRead)
		try container.encode(totalIssues, forKey: .totalIssues)
		try container.encode(pagesRead, forKey: .pagesRead)
	}
}

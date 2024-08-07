//
//  ComicEvent.swift
//  Comic Tracker
//
//  Created by James Coldwell on 28/7/2024.
//

import Foundation
import SwiftData

/**
 Stores all necessary data for a comic event
 */
@Model
class ComicEvent: Codable {
	/// this is used as a static id, so everytime i create a new event it gets incremented and given to that comic so they each get a unique id
	static var staticEventId: UInt32 = 0
	
	/// unique id for this event, mainly used internally, most likely wont be shown to the user
	var eventId: UInt32
	/// The full name of this event
	var eventName: String
	/// The total number of comic issues that have been read in this event (doesn't have to be in order)
	var issuesRead: UInt16
	/// The total number of comic issues this event has
	var totalIssues: UInt16
	/// The total number of pages read in all comic books in this event
	var pagesRead: UInt16
	
	
	init(eventName: String,
		 issuesRead: UInt16,
		 totalIssues: UInt16,
		 pagesRead: UInt16) {
		
		ComicEvent.staticEventId += 1
		self.eventId = ComicEvent.staticEventId
		self.eventName = eventName
		self.issuesRead = issuesRead
		self.totalIssues = totalIssues
		self.pagesRead = pagesRead
	}
	
	// needed to be able to encode this as json
	enum CodingKeys: String, CodingKey {
		case eventId
		case eventName
		case issuesRead
		case totalIssues
		case pagesRead
	}
	
	required init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		
		// the id is saved in the files to keep the order so i need to update the static id everytime so if i add a new event it is at the right value
		let tmpEventId = try container.decode(UInt32.self, forKey: .eventId)
		eventId = tmpEventId
		ComicEvent.staticEventId = tmpEventId
		
		eventName = try container.decode(String.self, forKey: .eventName)
		issuesRead = try container.decode(UInt16.self, forKey: .issuesRead)
		totalIssues = try container.decode(UInt16.self, forKey: .totalIssues)
		pagesRead = try container.decode(UInt16.self, forKey: .pagesRead)

	}
	
	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		
		try container.encode(eventId, forKey: .eventId)
		try container.encode(eventName, forKey: .eventName)
		try container.encode(issuesRead, forKey: .issuesRead)
		try container.encode(totalIssues, forKey: .totalIssues)
		try container.encode(pagesRead, forKey: .pagesRead)
	}
}

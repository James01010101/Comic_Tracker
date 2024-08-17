//
//  PreviewHelpers.swift
//  Comic Tracker
//
//  Created by James Coldwell on 17/8/2024.
//

import Foundation
import SwiftData


/// Takes in a context and creates lots of comics to test with.
///
/// should be used by all previews so i only write it once
func createTestComics(context: ModelContext) {
	// add some testing comics
	saveComic(
		brandName: "Marvel",
		shortBrandName: "",
		prioritizeShortBrandName: false,
		
		seriesName: "Infinity Gauntlet",
		shortSeriesName: "",
		prioritizeShortSeriesName: false,
		
		comicName: "",
		shortComicName: "",
		prioritizeShortComicName: false,
		
		yearFirstPublished: 1977,
		issueNumber: 1,
		totalPages: 30,
		eventName: "Infinity Gauntlet",
		purpose: "Thanos",
		dateRead: Date(),
		modelContext: context
	)
	
	saveComic(
		brandName: "Marvel",
		shortBrandName: "",
		prioritizeShortBrandName: false,
		
		seriesName: "Infinity Gauntlet",
		shortSeriesName: "",
		prioritizeShortSeriesName: false,
		
		comicName: "",
		shortComicName: "",
		prioritizeShortComicName: false,
		
		yearFirstPublished: 1977,
		issueNumber: 2,
		totalPages: 31,
		eventName: "Infinity Gauntlet",
		purpose: "Thanos",
		dateRead: Date(),
		modelContext: context
	)
	
	saveComic(
		brandName: "Star Wars",
		shortBrandName: "",
		prioritizeShortBrandName: false,
		
		seriesName: "Darth Vader",
		shortSeriesName: "",
		prioritizeShortSeriesName: false,
		
		comicName: "",
		shortComicName: "",
		prioritizeShortComicName: false,
		
		yearFirstPublished: 2015,
		issueNumber: 1,
		totalPages: 23,
		eventName: "Darth Vader",
		purpose: "Darth Vader",
		dateRead: Date(),
		modelContext: context
	)
	
	saveComic(
		brandName: "Star Wars",
		shortBrandName: "",
		prioritizeShortBrandName: false,
		
		seriesName: "Darth Vader",
		shortSeriesName: "",
		prioritizeShortSeriesName: false,
		
		comicName: "",
		shortComicName: "",
		prioritizeShortComicName: false,
		
		yearFirstPublished: 2015,
		issueNumber: 2,
		totalPages: 22,
		eventName: "Darth Vader",
		purpose: "Darth Vader",
		dateRead: Date(),
		modelContext: context
	)
	
	saveComic(
		brandName: "Star Wars",
		shortBrandName: "",
		prioritizeShortBrandName: false,
		
		seriesName: "Darth Vader",
		shortSeriesName: "",
		prioritizeShortSeriesName: false,
		
		comicName: "",
		shortComicName: "",
		prioritizeShortComicName: false,
		
		yearFirstPublished: 2020,
		issueNumber: 1,
		totalPages: 22,
		eventName: "Darth Vader",
		purpose: "Darth Vader",
		dateRead: Date(),
		modelContext: context
	)
	
	saveComic(
		brandName: "Five Nights At Freddy's",
		shortBrandName: "FNAF",
		prioritizeShortBrandName: false,
		
		seriesName: "The Silver Eyes",
		shortSeriesName: "",
		prioritizeShortSeriesName: false,
		
		comicName: "The Silver Eyes",
		shortComicName: "",
		prioritizeShortComicName: false,
		
		yearFirstPublished: 2014,
		issueNumber: 1,
		totalPages: 356,
		eventName: "FNAF",
		purpose: "FNAF",
		dateRead: Date(),
		modelContext: context
	)
	
	saveComic(
		brandName: "Five Nights At Freddy's",
		shortBrandName: "FNAF",
		prioritizeShortBrandName: false,
		
		seriesName: "The Silver Eyes",
		shortSeriesName: "",
		prioritizeShortSeriesName: false,
		
		comicName: "The Twisted Ones",
		shortComicName: "",
		prioritizeShortComicName: false,
		
		yearFirstPublished: 2014,
		issueNumber: 2,
		totalPages: 301,
		eventName: "FNAF",
		purpose: "FNAF",
		dateRead: Date(),
		modelContext: context
	)
	
	saveComic(
		brandName: "Five Nights At Freddy's",
		shortBrandName: "FNAF",
		prioritizeShortBrandName: false,
		
		seriesName: "The Silver Eyes",
		shortSeriesName: "",
		prioritizeShortSeriesName: false,
		
		comicName: "The Fourth Closet",
		shortComicName: "",
		prioritizeShortComicName: false,
		
		yearFirstPublished: 2014,
		issueNumber: 3,
		totalPages: 362,
		eventName: "FNAF",
		purpose: "FNAF",
		dateRead: Date(),
		modelContext: context
	)
	
	saveComic(
		brandName: "Marvel",
		shortBrandName: "",
		prioritizeShortBrandName: false,
		
		seriesName: "Deadpool & Wolverine: WWIII",
		shortSeriesName: "",
		prioritizeShortSeriesName: false,
		
		comicName: "",
		shortComicName: "",
		prioritizeShortComicName: false,
		
		yearFirstPublished: 2024,
		issueNumber: 1,
		totalPages: 29,
		eventName: "",
		purpose: "Deadpool",
		dateRead: Date(),
		modelContext: context
	)
	
	saveComic(
		brandName: "The Walking Dead",
		shortBrandName: "TWD",
		prioritizeShortBrandName: false,
		
		seriesName: "The Walking Dead Deluxe",
		shortSeriesName: "",
		prioritizeShortSeriesName: false,
		
		comicName: "",
		shortComicName: "",
		prioritizeShortComicName: false,
		
		yearFirstPublished: 2020,
		issueNumber: 1,
		totalPages: 30,
		eventName: "",
		purpose: "The Walking Dead",
		dateRead: Date(),
		modelContext: context
	)
	
	saveComic(
		brandName: "The Walking Dead",
		shortBrandName: "TWD",
		prioritizeShortBrandName: false,
		
		seriesName: "The Walking Dead Deluxe",
		shortSeriesName: "",
		prioritizeShortSeriesName: false,
		
		comicName: "",
		shortComicName: "",
		prioritizeShortComicName: false,
		
		yearFirstPublished: 2020,
		issueNumber: 2,
		totalPages: 31,
		eventName: "",
		purpose: "The Walking Dead",
		dateRead: Date(),
		modelContext: context
	)
	
	saveComic(
		brandName: "Jujutsu Kaisen",
		shortBrandName: "JJK",
		prioritizeShortBrandName: false,
		
		seriesName: "Jujutsu Kaisen",
		shortSeriesName: "JJK",
		prioritizeShortSeriesName: false,
		
		comicName: "",
		shortComicName: "",
		prioritizeShortComicName: false,
		
		yearFirstPublished: 2020,
		issueNumber: 1,
		totalPages: 192,
		eventName: "",
		purpose: "Jujutsu Kaisen",
		dateRead: Date(),
		modelContext: context
	)
	
	saveComic(
		brandName: "Jujutsu Kaisen",
		shortBrandName: "JJK",
		prioritizeShortBrandName: false,
		
		seriesName: "Jujutsu Kaisen",
		shortSeriesName: "JJK",
		prioritizeShortSeriesName: true,
		
		comicName: "",
		shortComicName: "",
		prioritizeShortComicName: false,
		
		yearFirstPublished: 2020,
		issueNumber: 2,
		totalPages: 192,
		eventName: "",
		purpose: "Jujutsu Kaisen",
		dateRead: Date(),
		modelContext: context
	)
}

//
//  CreateNewComics.swift
//  Comic Tracker
//
//  Created by James Coldwell on 9/8/2024.
//
// This file is a bunch of functions related to creating new comics, series and events, that should be accessable from all files. This is used to help the previews be able to create lots of temp data to be shown.

import Foundation
import SwiftData


/// Save the newly created comic to the modelContext.
///
/// This will also create a new ``ComicSeries`` and/or ``ComicEvent`` if it didnt exist before.
/// It will add to the ``ComicSeries`` and/or ``ComicEvent`` if they exist.
///
/// Once successfully saved or canceled this will return back to the calling view, usually the main ``ContentView``.
func saveComic(
	brandName: String,
	shortBrandName: String,
	prioritizeShortBrandName: Bool,
	
	seriesName: String,
	shortSeriesName: String,
	prioritizeShortSeriesName: Bool,
	
	comicName: String,
	shortComicName: String,
	prioritizeShortComicName: Bool,
	
	yearFirstPublished: UInt16,
	issueNumber: UInt16,
	totalPages: UInt16,
	eventName: String,
	purpose: String,
	dateRead: Date?,
	modelContext: ModelContext
) {
	
	let newComic = ComicData(
		brandName: brandName,
		shortBrandName: shortBrandName,
		prioritizeShortBrandName: prioritizeShortBrandName,
		
		seriesName: seriesName,
		shortSeriesName: shortSeriesName,
		prioritizeShortSeriesName: prioritizeShortSeriesName,
		
		comicName: comicName,
		shortComicName: shortComicName,
		prioritizeShortComicName: prioritizeShortComicName,
		
		yearFirstPublished: yearFirstPublished,
		issueNumber: issueNumber,
		totalPages: totalPages,
		eventName: eventName,
		purpose: purpose,
		dateRead: dateRead
	)
	
	// Insert into the model context
	modelContext.insert(newComic)
	
	// update the series if it exists or else create a new one
	updateSeriesWithNewComic(comic: newComic, modelContext: modelContext)
	
	// update the event if it exists or else create a new one
	updateEventWithNewComic(comic: newComic, modelContext: modelContext)
	
	// finally save the model
	try? modelContext.save()

}


/// Update the series with a new comic if it exists or else create a new series
/// - Parameter comic: The new ``ComicData`` which contains the informations about the new comic
func updateSeriesWithNewComic(comic: ComicData, modelContext: ModelContext) {
	let series: [ComicSeries] = try! modelContext.fetch(FetchDescriptor<ComicSeries>())
	let globalState = GlobalState.shared

	// Create a new series object for it if it doesnt exist
	if (comic.seriesName != "") { // should always have a series
		// See if i already have a series with the name
		var foundSeries = false
		for s in series {
			// for a series to be the same it needs the same title and same year
			if (comic.seriesName == s.seriesName && comic.yearFirstPublished == s.yearFirstPublished) {
				// the series exists so add to it
				s.issuesRead += 1
				s.pagesRead += comic.totalPages
				
				s.updateRecentComicStats(comic: comic)
				
				// dont want to continue searching
				foundSeries = true
				break
			}
		}
		
		// If I didn't find the series then i need to create it
		if (!foundSeries) {
			let newSeries = ComicSeries(
				brandName: comic.brandName,
				shortBrandName: comic.shortBrandName,
				prioritizeShortBrandName: comic.prioritizeShortBrandName,
				
				seriesName: comic.seriesName,
				shortSeriesName: comic.shortSeriesName,
				prioritizeShortSeriesName: comic.prioritizeShortSeriesName,
				
				yearFirstPublished: comic.yearFirstPublished,
				issuesRead: 1, // since this is the first comic in this series
				totalIssues: 0, // should never be 0 so this is default until set later
				pagesRead: comic.totalPages,
				recentComicIssueNumber: comic.issueNumber,
				recentComicTotalPages: comic.totalPages,
				recentComicEventName: comic.eventName,
				recentComicPurpose: comic.purpose
			)
			
			// check if it exists in the dict, if so add one, else add it
			if let count = globalState.seriesNamesUsages[comic.seriesName] {
				// if it exists
				globalState.seriesNamesUsages[comic.seriesName] = count + 1
			} else {
				globalState.seriesNamesUsages[comic.seriesName] = 1
			}

			// insert into the model context
			modelContext.insert(newSeries)
		}
	}
}


/// Update the event with a new comic if it exists or else create a new event
/// - Parameter comic: The new ``ComicData`` which contains the informations about the new comic
func updateEventWithNewComic(comic: ComicData, modelContext: ModelContext) {
	let events: [ComicEvent] = try! modelContext.fetch(FetchDescriptor<ComicEvent>())

	// Create a new event object for it if it doesnt exist
	if (comic.eventName != "") { // dont need a event
		// see if i already have a event with the name
		var foundEvent = false
		for e in events {
			if (comic.eventName == e.eventName) {
				// the event exists so add to it
				e.issuesRead += 1
				e.pagesRead += comic.totalPages
				
				// dont want to continue searching
				foundEvent = true
				break
			}
		}
		
		// If I didn't find the event then i need to create it
		if (!foundEvent) {
			let newEvent = ComicEvent(
				eventName: comic.eventName,
				issuesRead: 1,
				totalIssues: 0,
				pagesRead: comic.totalPages
			)
			// insert into the model context
			modelContext.insert(newEvent)
		}
	}
}

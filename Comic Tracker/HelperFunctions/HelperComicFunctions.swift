//
//  HelperComicFunctions.swift
//  Comic Tracker
//
//  Created by James Coldwell on 10/8/2024.
//

import Foundation
import SwiftData


/// Decrease the count of read comics in its series, if it drops to 0 delete the series.
///
/// This is called when a comic is being deleted, so it is being removed from the series it was apart of too
func removeComicFromSeries(comic: ComicData, allSeries: [ComicSeries]) {
	/// Controls all persistent data this view uses.
	let persistenceController = PersistenceController.shared
	let globalState = GlobalState.shared
	
	for series in allSeries {
		if (comic.seriesName == series.seriesName && comic.yearFirstPublished == series.yearFirstPublished) {
			
			series.issuesRead -= 1
			series.pagesRead -= comic.totalPages
			
			// decrease the series usages counter
			if let count = globalState.seriesNamesUsages[series.seriesName] {
				globalState.seriesNamesUsages[series.seriesName] = count - 1
				
				// if there is 0 <= usages then i can remove it from the dict
				if (count - 1 <= 0) {
					globalState.seriesNamesUsages.removeValue(forKey: series.seriesName)
				}
			}
			
			if (series.issuesRead <= 0) {
				// then delete the series
				persistenceController.context.delete(series)
			}
			
			break
		}
	}
}



/// Decrease the count of read comics in its event(s), if it drops to 0 delete the event.
///
/// This is called when a comic is being deleted, so it is being removed from the event it was apart of too
/// A comic could potentially be in more than one series, so i cant break after i find one ill have to loop through all of them.
func removeComicFromEvents(comic: ComicData, allEvents: [ComicEvent]) {
	
	for event in allEvents {
		if (comic.eventName == event.eventName) {
			
			event.issuesRead -= 1
			event.pagesRead -= comic.totalPages
			
			// at this point i dont want to delete the event because if i have created it myself i probably dont want to actually delete the whole thing if i just miss type a name of a comic, so ill levae it for now and i can manually delete it if i want
			/*
			if (event.issuesRead <= 0) {
				// then delete the series
				persistenceController.context.delete(event)
			}
			 */
			
			// i will break currently since comics only store one event but later i will remove this
			break
		}
	}
}



/// Go through and recalculate all of the ids of the comics so there isnt any gaps
/// 
/// eg so if it was 1, 2, 4, 5, 7
/// it goes to 1, 2, 3, 4, 5
/// Need to sort the comics array by id first to make sure i keep the correct order
/// - Parameter comics: List of all comics
func recalculateComicIds(comics: [ComicData]) {
	// sort the array by id
	let sortedComics = comics.sorted { $0.comicId < $1.comicId };

	// loop through the array and re calculate each comics id
	// updating sortedComics does update the actual comics array
	for i in 0..<sortedComics.count {
		sortedComics[i].comicId = UInt32(i+1);
	}
	ComicData.staticComicId = UInt32(sortedComics.count);
	print("Comic static id is now \(ComicData.staticComicId)");
}

/// Recalculate series ids so that there is no gaps in id
///
/// This is ran on first load each time the app is opened
/// - Parameter series: List of all series
func recalculateSeriesIds(series: [ComicSeries]) {
	// sort the array by id
	let sortedSeries = series.sorted { $0.seriesId < $1.seriesId };

	// loop through the array and re calculate each series id
	// updating sortedComics does update the actual series array
	for i in 0..<sortedSeries.count {
		sortedSeries[i].seriesId = UInt32(i+1);
	}
	ComicSeries.staticSeriesId = UInt32(sortedSeries.count);
	print("Series static id is now \(ComicSeries.staticSeriesId)");
}

/// Recalculate event ids so that there is no gaps in id
///
/// This is ran on first load each time the app is opened
/// - Parameter events: List of all events
func recalculateEventsIds(events: [ComicEvent]) {
	// sort the array by id
	let sortedEvents = events.sorted { $0.eventId < $1.eventId };

	// loop through the array and re calculate each events id
	// updating sortedComics does update the actual events array
	for i in 0..<sortedEvents.count {
		sortedEvents[i].eventId = UInt32(i+1);
	}
	ComicEvent.staticEventId = UInt32(sortedEvents.count);
	print("Events static id is now \(ComicEvent.staticEventId)");
}



// Unused but was used to delete all series and re add them from the array of comics
// Ill leave this because it might be helpful later, was used because the series ids wernt unique so i needed to delete them all and the add them back in in the right order
func recalcAllSeries(series: [ComicSeries], comics: [ComicData], modelContext: ModelContext) {
	let sortedComics = comics.sorted { $0.comicId < $1.comicId };
	
	var series = series;
	
	print("Series before")
	for i in 0..<series.count {
		print("\(series[i].seriesId): \(series[i].seriesName)");
	}
	
	// delete all series
	// Loop through and delete each one
	for s in series {
		modelContext.delete(s)
	}
	
	ComicSeries.staticSeriesId = 0;
	
	
	var fetchRequestComicSeries = FetchDescriptor<ComicSeries>();
	do {
		series = try modelContext.fetch(fetchRequestComicSeries)
	} catch {
		print("Failed to recalculate comic's ids, unable to load ComicData from context: \(error)")
	}
	print("Series after delete")
	for i in 0..<series.count {
		print("\(series[i].seriesId): \(series[i].seriesName)");
	}
	
	// go through each comic and add it to the series like i would normally add a new comic
	for newComic in sortedComics {
		// update the series if it exists or else create a new one
		updateSeriesWithNewComic(comic: newComic, modelContext: modelContext);
	}
	
	fetchRequestComicSeries = FetchDescriptor<ComicSeries>();
	do {
		series = try modelContext.fetch(fetchRequestComicSeries)
	} catch {
		print("Failed to recalculate comic's ids, unable to load ComicData from context: \(error)")
	}
	print("Series after add back")
	for i in 0..<series.count {
		print("\(series[i].seriesId): \(series[i].seriesName)");
	}
	
	// finally save the model
	try? modelContext.save()
}

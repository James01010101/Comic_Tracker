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

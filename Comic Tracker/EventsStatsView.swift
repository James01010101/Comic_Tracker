//
//  EventsStatsView.swift
//  Comic Tracker
//
//  Created by James Coldwell on 10/8/2024.
//

import Foundation
import SwiftUI
import SwiftData

/// This contains a list of all of the events I have with a bunch of statistics for each event
struct EventsStatsView: View {
	
	/// Controls all persistent data this view uses.
	@StateObject private var persistenceController = PersistenceController.shared
	/// Controls all global variables this view uses.
	@StateObject private var globalState = GlobalState.shared
	
	
	/// Stores an array of ``ComicEvent`` which contains all of the individual comic events, which are stored in the ``PersistenceController``.
	@Query private var events: [ComicEvent]
	
	
	/// Width of the `readId` element in the list
	///
	/// Used to get nice spacing and to allow the comic name to have the most space possible
	private let readIdWidth: CGFloat = 45
	
	// top section
	private let eventsIdLeadingPadding : CGFloat = -12
	
	// bottom section
	private let statMajorWidth: CGFloat = 75
	private let statMajorTopPadding: CGFloat = -15
	private let majorDividerBottomPadding: CGFloat = 10
	private let issuesStatsTopPadding: CGFloat = -5
	private let minorIssuesVerticalDividerPaddingTop: CGFloat = 8
	private let minorIssuesVerticalDividerPaddingBottom: CGFloat = 10
	
	
	// main view body
	var body: some View {
		NavigationStack {
			VStack {
				// headings stack
				VStack(spacing: 0) {
					HStack {
						Text("ID")
							.frame(width: readIdWidth, alignment: .center)
							.font(.headline)
							.padding(.leading, 10)
						
						Text("Series Name")
							.frame(maxWidth: .infinity, alignment: .center)
							.font(.headline)
							.padding(.leading, -10 - readIdWidth) // to adjust for the pages text being moved in slightly more
							.padding(.trailing, 10)
					}
					.padding(.top, 10)
					.padding(.bottom, -5)
					
					// Divider
					Rectangle()
						.frame(height: 3)  // Adjust the height for a bolder line
						.padding(.top, 10)  // Optional: Add some padding below the divider
						.padding(.horizontal, 10) // insert the boarder line slightly from the edges of the screen
				}
				
				// VStack list for all the series
				// the series will take up to lines each
				// one for the series, and one for stats
				List {
					ForEach(events) { event in
						// this row
						VStack {

							// top row name
							HStack {
								Text(String(event.eventId))
									.frame(width: 25, alignment: .center)
									.padding(.leading, eventsIdLeadingPadding)
								
								Divider()
									.padding(.top, 1)
								
								Text(getEventsFormattedName(event: event))
									.font(.headline)
									// force it to take up all the space so the id gets forced to the left
									.frame(maxWidth: .infinity)
									// remove as much padding from either side to give it as much space as possible (it is centered so normally you wont tell anyway)
									.padding(.leading, -5)
									.padding(.trailing, -15)
							}
							.frame(height: 25)
							.padding(.bottom, -3)
							
							Divider()
								.padding([.leading, .trailing], -10) // extend the sides of the divider
							
							// bottom row stats
							HStack {
								
								VStack {
									Text("Issues")
										.padding([.top, .bottom], -6)
									
									Divider()
									
									HStack {
										VStack {
											Text("Total")
											Text(String(event.totalIssues))
												.frame(maxWidth: .infinity)
										}
										.padding(.top, issuesStatsTopPadding)
										
										Divider()
											.padding(.top, minorIssuesVerticalDividerPaddingTop)
											.padding(.bottom, minorIssuesVerticalDividerPaddingBottom)
										
										VStack {
											Text("Read")
											Text(String(event.issuesRead))
												.frame(maxWidth: .infinity)
										}
										.padding(.top, issuesStatsTopPadding)
										
										Divider()
											.padding(.top, minorIssuesVerticalDividerPaddingTop)
											.padding(.bottom, minorIssuesVerticalDividerPaddingBottom)
										
										VStack {
											Text("Left")
											Text(getIssuesLeft(event: event))
												.frame(maxWidth: .infinity)
										}
										.padding(.top, issuesStatsTopPadding)
									}
									.padding(.top, -8)
								}
								
								Divider()
									.padding(.bottom, majorDividerBottomPadding)
								
								VStack {
									Text("Pages")
									Text(String(event.pagesRead))
										.frame(width: statMajorWidth)
								}
								.padding(.top, statMajorTopPadding)
							}
							.frame(maxWidth: .infinity, alignment: .center)
							.padding([.leading, .trailing], -15)
							.padding(.bottom, -8)
						}
					}
				}
				// this shrinks the gap at the top of the list so it sits under the headers nicely
				.onAppear(perform: {
					UICollectionView.appearance().contentInset.top = -35
				})
				// less padding either side of the list
				.padding(.leading, -10)
				.padding(.trailing, -10)
				.listRowSpacing(8)
			}
			.navigationTitle("Comic Events")
		}
	}
	
	
	/// Takes a event and returns a nicely formatted string to represent it.
	/// - Parameter series: ``ComicEvent`` which contains all the information about the event.
	/// - Returns: Formatted `String` representing the event.
	private func getEventsFormattedName(event: ComicEvent) -> String {
		var formattedString: String = ""
		formattedString = event.eventName
		
		return formattedString
	}
	
	
	
	/// Get the number of issues left to read in this event.
	///
	/// This is done as a function because the values are UInt and i am subtracting it the app can crash if i underflow without catching that.
	///
	/// - Parameter series: A ``ComicEvent`` containing all the information about the event.
	/// - Returns: `String` which is the number of issues left to read, or 0 if failed.
	private func getIssuesLeft(event: ComicEvent) -> String {
		let read: UInt16 = event.issuesRead
		let total: UInt16 = event.totalIssues
		var left: Int = 0
		
		// I haven't set the total yet
		if (total == 0) {
			return "0"
		}
		else {
			// convert to int first, if i have read more than i have set as total itll be negative
			// if they stay as UInt then it will break and crash
			// so set to Int, if the result is negative then ive read than many more books than the total
			left = Int(total) - Int(read)
			return String(left)
		}
	}
}




/// Main view preview settings
struct EventsStatsView_Previews: PreviewProvider {
	static var previews: some View {
		// create the model context
		let schema = Schema([
			ComicData.self,
			ComicSeries.self,
			ComicEvent.self
		])
		let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
		var container: ModelContainer
		var context: ModelContext
		do {
			container = try ModelContainer(for: schema, configurations: [modelConfiguration])
			context = ModelContext(container)
		} catch {
			fatalError("Could not create ModelContainer: \(error)")
		}
		
		// reset to 0 since the preview can be loaded multiple times and this will keep incrementing
		ComicData.staticComicId = 0
		ComicSeries.staticSeriesId = 0
		ComicEvent.staticEventId = 0
		
				
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
			brandName: "FNAF",
			shortBrandName: "",
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
			brandName: "FNAF",
			shortBrandName: "",
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
			brandName: "FNAF",
			shortBrandName: "",
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
			shortBrandName: "",
			prioritizeShortBrandName: false,
			
			seriesName: "The Walking Dead",
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
			shortBrandName: "",
			prioritizeShortBrandName: false,
			
			seriesName: "The Walking Dead",
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
		
		// lastly save it
		try? context.save()
		
		return EventsStatsView()
			.environment(\.modelContext, context)
	}
}


//
//  ContentView.swift
//  Comic Tracker
//
//  Created by James Coldwell on 28/7/2024.
//

import Foundation
import SwiftUI
import SwiftData

/// The main view in my project.
struct ContentView: View {
	/// Controls all persistent data this view uses.
	@StateObject private var persistenceController = PersistenceController.shared
	/// Controls all global variables thie view uses.
	@StateObject private var globalState = GlobalState.shared
	
	
	// all of my apps views
	/// Used to toggle between this main view and the ``AddNewComicView``
	@State private var navigateToAddNewComicView: Bool = false
	/// Used to toggle between this main view and the ``SeriesStatsView``
	@State private var navigateToSeriesStatsView: Bool = false
	/// Used to toggle between this main view and the ``EventsStatsView``
	@State private var navigateToEventsStatsView: Bool = false
	
	
	// query variables (these are stored in the modelContext and are persistant)
	/// Stores an array of ``ComicData`` which contains all of the individual comic books, which are stored in the ``PersistenceController``.
	///
	/// This is sorted in decending order on the `comicId` to correctly be shown in  order in the list.
	@Query(sort: \ComicData.comicId, order: .reverse) private var comics: [ComicData]
	/// Stores an array of ``ComicSeries`` which contains all of the individual comic series, which are stored in the ``PersistenceController``.
	@Query private var series: [ComicSeries]
	/// Stores an array of ``ComicEvent`` which contains all of the individual comic events, which are stored in the ``PersistenceController``.
	@Query private var events: [ComicEvent]
	
	/// currently selected comic, saved so i can send it to the add new comic view when needed
	@State private var selectedComic: ComicData?
	
	
	/// Width of the `readId` element in the list
	///
	/// Used to get nice spacing and to allow the comic name to have the most space possible
	private let readIdWidth: CGFloat = 45
	/// Width of the `pagesRead` element in the list
	///
	/// Used to get nice spacing and to allow the comic name to have the most space possible
	private let pagesWidth: CGFloat = 35
	
	
	/// Main body of the main view.
	var body: some View {
		NavigationStack {
			VStack() {
				// headings stack
				VStack() {
					HStack {
						Text("ID")
							.frame(width: readIdWidth, alignment: .center)
							.font(.headline)
							.padding(.leading, 15)
						
						Text("Comic Name")
							.frame(maxWidth: .infinity, alignment: .center)
							.font(.headline)
							.padding(.leading, 15) // to adjust for the pages text being moved in slightly more
						
						Text("Pages")
							.frame(width: pagesWidth + 15, alignment: .center)
							.font(.headline)
							.padding(.trailing, 15)
					}
					.padding(.bottom, -5)
					
					// Divider
					Rectangle()
						.frame(height: 3)  // Adjust the height for a bolder line
						.padding(.top, 10)  // Optional: Add some padding below the divider
						.padding(.horizontal, 10) // insert the boarder line slightly from the edges of the screen
				}
				
				// list of comics stack
				VStack {
					List {
						// most recently read comics
						ForEach(comics) { comic in
							HStack {
								Text(String(comic.comicId))
									.frame(width: readIdWidth, alignment: .center)
									.padding(.leading, -10)
								
								Divider()
								
								
								Text(createDisplayedComicString(comic: comic))
									.frame(maxWidth: .infinity, alignment: .leading)
								
								Divider()
								
								Text(String(comic.totalPages))
									.frame(width: pagesWidth, alignment: .center)
									.padding(.trailing, -10)
							}
							.padding(.vertical, -3)  // Optional: Add some vertical padding between row
							.swipeActions(edge: .leading) {
								Button(action: {
									selectedComic = comic
									goToAddNewComicView()
								}) {
									Label("Add Comic From Series", systemImage: "plus")
								}
								.tint(.green)
							}

						}
						.onDelete(perform: deleteItems)
					}
					.padding(.leading, -10)
					.padding(.trailing, -10)
					.listRowSpacing(8)
				}
			}
			// toolbar for the buttons
			.toolbar {
				// left side
				ToolbarItem(placement: .topBarLeading) {
					// saved all data to their files, shows a different icon depending on the success of the save
					Button(action: {
						globalState.saveDataIcon = persistenceController.saveAllData()
					}) {
						if let saveDataIcon = globalState.saveDataIcon {
							if (saveDataIcon) {
								// successful backup
								Label("Backup Data", systemImage: "checkmark")
							} else {
								// failed backup
								Label("Backup Data", systemImage: "xmark")
							}
						} else { // returned nil
							// default
							Label("Backup Data", systemImage: "square.and.arrow.down")
						}
					}
				}
				ToolbarItem(placement: .topBarLeading) {
					Button(action: goToSeriesView) {
						Label("Go To Series View", systemImage: "s.circle")
					}
				}
				ToolbarItem(placement: .topBarLeading) {
					Button(action: goToEventsView) {
						Label("Go To Events View", systemImage: "e.circle")
					}
				}
				
				// right side
				ToolbarItem(placement: .topBarTrailing) {
					// add new comic button
					Button(action: {
						selectedComic = nil
						goToAddNewComicView()
					}) {
						Label("Add Comic", systemImage: "plus")
					}
				}
				ToolbarItem(placement: .topBarTrailing) {
					EditButton()
				}
			}
			.navigationTitle("Recent Comics")
			// rules to navigating to other views
			.navigationDestination(isPresented: $navigateToAddNewComicView) {
				if let c = selectedComic {
					// set it back to nil so i can click the plus and have an empty new comic view. otherwise once i create from a recent comic i wont be able to create a new empty comic
					AddNewComicView(comic: c)
				
				// if it fails just dont auto fill
				} else {
					AddNewComicView()
				}
			}
			.navigationDestination(isPresented: $navigateToSeriesStatsView) {
				SeriesStatsView()
			}
			.navigationDestination(isPresented: $navigateToEventsStatsView) {
				EventsStatsView()
			}
		}
	}
	
	
	/// Nicely formats a string containing important information to uniquely identify a comic.
	///
	/// Used in the recent comic list
	///
	/// Default format is: {brand}: {series} {year}\n {individualComicName} #{issueNumber}
	///
	///
	/// - There are some unique cases which need to be taken into account:
	///   - If the comic has an `comicName` it will be shown.
	///   - If the comic has the same `seriesName` as another series, the `yearFirstPublished` will be added after the series to uniquely identify it.
	///   - If the `seriesName` is the same as the `brand` then it will also be omitted, as to not have duplicated phrases.
	///
	/// > Important: Not all formatting cases are implemented yet.
	///
	/// - Parameter comic: An instance of ``ComicData`` that contains all the information about the comic.
	/// - Returns: Nicely formatted `String` to be displayed to the user in the comic list.
	private func createDisplayedComicString(comic: ComicData) -> String {
		var displayedString: String = ""
		
		displayedString += comic.brandName + ":\n"
		displayedString += comic.seriesName
		
		// do series collision checks and add year on if needed
		if let count = globalState.seriesNamesUsages[comic.seriesName] {
			if (count > 1) {
				displayedString += " (" + String(comic.yearFirstPublished) + ")"
			}
		}
		
		displayedString += " #" + String(comic.issueNumber)
		
		if (!comic.comicName.isEmpty) {
			displayedString += "\n" + comic.comicName
		}
		
		return displayedString
	}
	
	
	/// Send the user to an empty ``AddNewComicView`` to add a brand new comic book from a new series.
	///
	/// This is ran when selecting 'New Series' in the action sheet. This will create a new ``ComicSeries`` and/or a new ``ComicEvent`` if needed. Otherwise will add to them if they already exist.
	private func goToAddNewComicView() {
		navigateToAddNewComicView = true
	}
	
	/// Send the user to ``SeriesStatsView`` to view all series and stats.
	///
	/// This is ran when selecting 'S' in the nav bar. This will show a list of all of the series and their stats.
	private func goToSeriesView() {
		navigateToSeriesStatsView = true
	}
	
	/// Send the user to ``EventsStatsView`` to view all events and stats.
	///
	/// This is ran when selecting 'E' in the nav bar. This will show a list of all of the events and their stats.
	private func goToEventsView() {
		navigateToEventsStatsView = true
	}
	
	/// Send the user to a partially auto filled ``AddNewComicView`` to add a new comic book to an already existing series.
	///
	/// This is ran when selecting 'Continuing Series' in the action sheet. This will automatically populate lots of the fields so the user doesn't have to manually input all of them. It will also create a new ``ComicEvent`` if needed. It will add to the ``ComicEvent`` and ``ComicSeries`` if they exist.
	///
	/// - Fields that will be autofilled:
	///   - `brand`
	///   - `seriesName`
	///   - `yearFirstPublished`
	///   - `issueNumber`: Previous issue number + 1
	///   - `totalPages`: Auto filled from previous comic in the series (will most likely need to be changed)
	///   - `eventName`
	///   - `purpose`
	///   - `dateRead`: Will be today's date
	///
	/// - Fields not autofilled:
	///   - `individualComicName`: Will be unique to each comic
	private func addContinuingSeriesComic() {
		navigateToAddNewComicView = true
	}
	
	
	/// Called when an item is deleted from the ``ComicData`` list.
	/// 
	/// Will delete an instance of ``ComicData`` from the ``modelContext`` given by the index.
	/// - Parameter offsets: An ``IndexSet`` used to delete the correct element from the  ``ComicData`` array.
	///
	/// > Note: Will automatically save the data if `GlobalState.autoSave` is on.
	private func deleteItems(offsets: IndexSet) {
		withAnimation {
			for index in offsets {
				persistenceController.context.delete(comics[index])
			}
		}
		
		// autosave
		if (globalState.autoSave) {
			globalState.saveDataIcon = persistenceController.saveAllData()
		} else {
			// need to manually because there have been changes
			globalState.saveDataIcon = nil
		}
	}
}


/// Main view preview settings
struct ContentView_Previews: PreviewProvider {
	
	static let initializeData: ModelContext = {
		// create the model context
		let schema = Schema([
			ComicData.self,
			ComicSeries.self,
			ComicEvent.self,
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
		
		print("Loading ContentView_Previews")
		
		// reset to 0 since the preview can be loaded multiple times and this will keep incrementing
		ComicData.staticComicId = 0
		ComicSeries.staticSeriesId = 0
		ComicEvent.staticEventId = 0
		
		let globalState = GlobalState.shared
		globalState.resetSeriesNamesUsages()
		
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
		
		// lastly save it
		try? context.save()
		return context
	}()
	
	static var previews: some View {
		return ContentView()
			.environment(\.modelContext, initializeData)
			.environmentObject(GlobalState.shared)
	}
}

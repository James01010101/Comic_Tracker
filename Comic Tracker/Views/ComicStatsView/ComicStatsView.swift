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
struct ComicStatsView: View {
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
	
	/// needed so i can sort the comies how i like as the above comies is read only and cant be changed myself to sort it
	@State private var sortedComics: [ComicData] = []
	
	// only define the options i want for sorting comics not all
	let sortOptionsForComics: [SortOption] = [.id, .pagesRead]
	
	// how am i sorting my list of series
	@State private var selectedSortOption: SortOption = .id
	
	
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
						.frame(height: 3) // Adjust the height for a bolder line
						.padding(.top, 10) // Optional: Add some padding below the divider
						.padding(.horizontal, 10) // insert the boarder line slightly from the edges of the screen
				}
				
				// the sorting dropdown
				VStack {
					Menu {
						Picker(selection: $selectedSortOption, label: Text("Sort Options")) {
							ForEach(sortOptionsForComics) { option in
								Text(option.rawValue).tag(option)
							}
						}
					} label: {
						Label("Sort by: \(selectedSortOption.rawValue)", systemImage: "arrow.up.arrow.down")
							.padding()
					}
					.onChange(of: selectedSortOption) {
						sortComics()
					}
					.onAppear {
						sortComics() // Initial sorting on view load
					}
					.frame(height: 30)
				}
				
				
				// list of comics stack
				VStack {
					List {
						// most recently read comics
						ForEach(sortedComics) { comic in
							HStack {
								Text(String(comic.comicId))
									.frame(width: readIdWidth, alignment: .center)
									.padding(.leading, -10)
									.modifier(MainDisplayTextStyle(globalState: globalState))

								
								Divider()
								
								VStack {
									// brand text
									let brandText = createDisplayedComicBrandString(comic: comic);
									if !brandText.isEmpty {
										Text(brandText)
											.frame(maxWidth: .infinity, alignment: .center)
											.modifier(MainDisplayTextStyle(globalState: globalState))
									}
									
									// series year and issue text
									let seriesText = createDisplayedComicSeriesString(comic: comic)
									if !seriesText.isEmpty {
										Text(seriesText)
											.frame(maxWidth: .infinity, alignment: .center)
											.modifier(MainDisplayTextStyle(globalState: globalState))
									}
									
									// comic name / book text
									let comicNameText = createDisplayedComicNameString(comic: comic)
									if !comicNameText.isEmpty {
										Text(comicNameText)
											.frame(maxWidth: .infinity, alignment: .center)
											.modifier(MainDisplayTextStyle(globalState: globalState))
									}
									
									// old formatting
									/*
									Text(createDisplayedComicString(comic: comic))
										.frame(maxWidth: .infinity, alignment: .leading)
										.modifier(MainDisplayTextStyle(globalState: globalState))
									 */
								}

								Divider()
								
								Text(String(comic.totalPages))
									.frame(width: pagesWidth, alignment: .center)
									.padding(.trailing, -10)
									.modifier(MainDisplayTextStyle(globalState: globalState))

							}
							.listRowBackground(globalState.getBrandColor(brandName: comic.brandName))
							.padding(.vertical, -3) // Optional: Add some vertical padding between row
							.swipeActions(edge: .leading) {
								Button(action: {
									selectedComic = comic
									navigateToAddNewComicView = true
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
					Button(action: {
						navigateToSeriesStatsView = true
					}) {
						Label("Go To Series View", systemImage: "s.circle")
					}
				}
				ToolbarItem(placement: .topBarLeading) {
					Button(action: {
						navigateToEventsStatsView = true
					}) {
						Label("Go To Events View", systemImage: "e.circle")
					}
				}
				
				// right side
				ToolbarItem(placement: .topBarTrailing) {
					// add new comic button
					Button(action: {
						selectedComic = nil
						navigateToAddNewComicView = true
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
	
	
	/// Sorts the Comics based on its enum chosen
	private func sortComics() {
		switch selectedSortOption {
			case .id:
				sortedComics = comics.sorted { $0.comicId > $1.comicId };
				
			case .pagesRead:
				sortedComics = comics.sorted { $0.totalPages > $1.totalPages };
			
			// not all enums are included so this is required
			default:
				break
		}
	}
	
	
	/// work out what i need to display as the brand for this comic
	private func createDisplayedComicBrandString(comic: ComicData) -> String {
		var brandNameString: String = comic.prioritizeShortBrandName ? comic.shortBrandName : comic.brandName
		// if the brand and comic name is the same ill show the (year maybe if needed) and issue number on this line
		if (comic.brandName == comic.seriesName) {
			if let count = globalState.seriesNamesUsages[comic.seriesName] {
				if (count > 1) {
					brandNameString += " (" + String(comic.yearFirstPublished) + ")"
				}
			}
			brandNameString += " #" + String(comic.issueNumber)
		}
		return brandNameString;
	}
	
	/// work out what i need to display as the series for this comic
	private func createDisplayedComicSeriesString(comic: ComicData) -> String {
		var seriesNameString: String = ""
		if (comic.brandName != comic.seriesName) {
			seriesNameString = comic.prioritizeShortSeriesName ? comic.shortSeriesName : comic.seriesName
			if let count = globalState.seriesNamesUsages[comic.seriesName] {
				if (count > 1) {
					seriesNameString += " (" + String(comic.yearFirstPublished) + ")"
				}
			}
			seriesNameString += " #" + String(comic.issueNumber)
		}
		return seriesNameString
	}
	
	/// work out what i need to display as the comic name for this comic
	private func createDisplayedComicNameString(comic: ComicData) -> String {
		if (!comic.comicName.isEmpty) {
			return comic.comicName
		}
		return ""
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
	/// > Important: This is not used anymore. there is seperate functions for the brand, series and book name so they can all be on seperate lines and still centered, they should visually look the same as this did.
	///
	/// - Parameter comic: An instance of ``ComicData`` that contains all the information about the comic.
	/// - Returns: Nicely formatted `String` to be displayed to the user in the comic list.
	private func createDisplayedComicString(comic: ComicData) -> String {
		var displayedString: String = ""
		let brandNameString: String = comic.prioritizeShortBrandName ? comic.shortBrandName : comic.brandName
		let seriesNameString: String = comic.prioritizeShortSeriesName ? comic.shortSeriesName : comic.seriesName
		
		displayedString += brandNameString
		
		if (comic.brandName != comic.seriesName) {
			displayedString += ":\n"
			displayedString += seriesNameString
		}
		
		
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
	
	
	/// Called when an item is deleted from the ``ComicData`` list.
	///
	/// Will delete an instance of ``ComicData`` from the ``modelContext`` given by the index.
	/// - Parameter offsets: An ``IndexSet`` used to delete the correct element from the  ``ComicData`` array.
	///
	/// > Note: Will automatically save the data if `GlobalState.autoSave` is on.
	private func deleteItems(offsets: IndexSet) {
		withAnimation {
			for index in offsets {
				// get the comic to delete from the sortedCOmics as this is what is shown to the user so this order is what i need to find the comic from
				let comic = sortedComics[index]
				
				print("Sorted comic to delete is \(comic.id) \(comic.seriesName)")
				
				// now delete this comic from everything
				// find the comic series and decrease the number of read comics
				removeComicFromSeries(comic: comic, allSeries: series)
				
				// find all events this comic was apart of and decrease the total number os issues read
				removeComicFromEvents(comic: comic, allEvents: events)
				
				// delete the comic
				persistenceController.context.delete(comic)
				
				// remove the element from the sorted comics
				sortedComics.remove(at: index)
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
struct ComicStatsView_Previews: PreviewProvider {
	static var previews: some View {
		
		let persistenceController = PersistenceController.shared
		let globalState = GlobalState.shared
		
		globalState.runningInPreview = true
		
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
		
		
		// reset to 0 since the preview can be loaded multiple times and this will keep incrementing
		ComicData.staticComicId = 0
		ComicSeries.staticSeriesId = 0
		ComicEvent.staticEventId = 0
		
		globalState.resetSeriesNamesUsages()
		
		// add some testing comics
		createTestComics(context: context)
		
		// lastly save it
		try? context.save()
		
		// set the context so my created preview one
		// so itll create the persistence controller like normal but then to context wont be whatever i have on disk itll be what i create here
		// this way creating and deleting comics will work correctly
		persistenceController.context = context
		
		return ComicStatsView()
			.environment(\.modelContext, context)
	}
}

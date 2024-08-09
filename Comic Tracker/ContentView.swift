//
//  ContentView.swift
//  Comic Tracker
//
//  Created by James Coldwell on 28/7/2024.
//

import SwiftUI
import SwiftData

/// The main view in my project.
struct ContentView: View {
	/// Stores all of the data this view uses.
	/// > Important: Should be removed later and all data modifications should go through the ``PersistenceController``
	@Environment(\.modelContext) private var modelContext: ModelContext
	
	/// Controls all persistent data this view uses.
	@StateObject private var persistenceController = PersistenceController.shared
	/// Controls all global variables thie view uses.
	@StateObject private var globalState = GlobalState.shared
	
	
	// all of my apps views
	/// Used to toggle between this main view and the ``AddNewComicView``
	@State private var navigateToAddNewComicView: Bool = false
	
	
	// query variables (these are stored in the modelContext and are persistant)
	/// Stores an array of ``ComicData`` which contains all of the individual comic books, which are stored in the ``PersistenceController``.
	///
	/// This is sorted in decending order on the `comicId` to correctly be shown in  order in the list.
	@Query(sort: \ComicData.comicId, order: .reverse) private var comics: [ComicData]
	/// Stores an array of ``ComicSeries`` which contains all of the individual comic series, which are stored in the ``PersistenceController``.
	@Query private var series: [ComicSeries]
	/// Stores an array of ``ComicEvent`` which contains all of the individual comic events, which are stored in the ``PersistenceController``.
	@Query private var events: [ComicEvent]
	
	
	/// Used to trigger the add new comic action sheet with options of new or continuing series.
	@State private var showingAddNewActionSheet: Bool = false
	
	
	
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
			VStack {
				// headings stack
				VStack(spacing: 0) {
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
					.padding(.top, 10)
					.padding(.bottom, -5)
					
					// Divider
					Rectangle()
						.frame(height: 3)  // Adjust the height for a bolder line
						.padding(.top, 10)  // Optional: Add some padding below the divider
						.padding(.horizontal, 10) // insert the boarder line slightly from the edges of the screen
				}
				
				// list of comics stack
				List {
					// most recently read comics
					ForEach(comics) { comic in
						HStack {
							Text(String(comic.comicId))
								.frame(width: readIdWidth, alignment: .trailing)
								.padding(.leading, -10)
							
							Divider()
							
							Text(createDisplayedComicString(comic: comic))
								.frame(maxWidth: .infinity, alignment: .leading)
							
							Divider()
							
							Text(String(comic.totalPages))
								.frame(width: pagesWidth, alignment: .leading)
								.padding(.trailing, -10)
						}
						.padding(.vertical, -3)  // Optional: Add some vertical padding between rows
					}
					.onDelete(perform: deleteItems)
				}
				// this shrinks the gap at the top of the list so it sits under the headers nicely
				.onAppear(perform: {
					UICollectionView.appearance().contentInset.top = -35
				})
				// less padding either side of the list
				.padding(.leading, -10)
				.padding(.trailing, -10)
				
				
				// toolbar for the buttons
				.toolbar {
					ToolbarItem(placement: .navigation) {
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
					ToolbarItem(placement: .navigationBarTrailing) {
						EditButton()
					}
					ToolbarItem {
						// add new comic button
						Button(action: addItem) {
							Label("Add Comic", systemImage: "plus")
						}
					}
				}
				
				// when the add button is clicked show an action menu so you know to create a new or continuing series
				.actionSheet(isPresented: $showingAddNewActionSheet) {
					ActionSheet(
						title: Text("Add New Comic"),
						buttons: [
							.default(Text("New Series")) {
								print("Adding New Series Comic")
								// Handle new item creation
								addNewComic()
							},
							.default(Text("Continuing Series")) {
								print("Adding Continuing Series Comic")
								// Handle continuing series
								addContinuingSeriesComic()
							},
							.cancel()
						]
					)
				}
			}
			.navigationTitle("Recent Comics")
			.navigationBarTitleDisplayMode(.inline)
			// rules to navigating to other views
			.navigationDestination(isPresented: $navigateToAddNewComicView) {
				AddNewComicView()
			}
		}
	}
	
	
	/// Nicely formats a string containing important information to uniquely identify a comic.
	///
	/// Used in the recent comic list
	///
	/// Default format is: {brand}: {series}\n {individualComicName} #{issueNumber}
	///
	/// - There are some unique cases which need to be taken into account:
	///   - If the comic has an `individualComicName` it will be shown. Otherwise, if it is empty, or the same as the `seriesName`, it will be omitted.
	///   - If the comic has the same `seriesName` as another series, the `yearFirstPublished` will be added after the series to uniquely identify it.
	///   - If the `seriesName` is the same as the `brand` then it will also be omitted, as to not have duplicated phrases.
	///
	/// > Important: Not all formatting cases are implemented yet.
	///
	/// - Parameter comic: An instance of ``ComicData`` that contains all the information about the comic.
	/// - Returns: Nicely formatted `String` to be displayed to the user in the comic list.
	private func createDisplayedComicString(comic: ComicData) -> String {
		var displayedString: String = ""
		displayedString += comic.brand + ": "
		displayedString += comic.seriesName
		
		if (!comic.individualComicName.isEmpty) {
			displayedString += "\n" + comic.individualComicName
		} else {
			displayedString += " #" + String(comic.issueNumber)
			
		}
		
		return displayedString
	}
	
	
	/// Send the user to an empty ``AddNewComicView`` to add a brand new comic book from a new series.
	///
	/// This is ran when selecting 'New Series' in the action sheet. This will create a new ``ComicSeries`` and/or a new ``ComicEvent`` if needed. Otherwise will add to them if they already exist.
	private func addNewComic() {
		navigateToAddNewComicView = true
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
	
	
	/// Will show the 'Add New Comic' action sheet when the add button is pressed.
	private func addItem() {
		showingAddNewActionSheet = true
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
				modelContext.delete(comics[index])
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
	static var previews: some View {
		let container = try! ModelContainer(
			for: ComicData.self, ComicSeries.self, ComicEvent.self,
			configurations: ModelConfiguration(isStoredInMemoryOnly: true)
		)
		
		let modelContext = ModelContext(container)
		
		// add some testing comics
		var newComic = ComicData(
			brand: "Marvel",
			seriesName: "Infinity Gauntlet",
			individualComicName: "",
			yearFirstPublished: 1977,
			issueNumber: 1,
			totalPages: 30,
			eventName: "Infinity Gauntlet",
			purpose: "Thanos",
			dateRead: Date()
		)
		modelContext.insert(newComic)
		
		newComic = ComicData(
			brand: "Marvel",
			seriesName: "Infinity Gauntlet",
			individualComicName: "",
			yearFirstPublished: 1977,
			issueNumber: 2,
			totalPages: 31,
			eventName: "Infinity Gauntlet",
			purpose: "Thanos",
			dateRead: Date()
		)
		modelContext.insert(newComic)
		
		newComic = ComicData(
			brand: "Star Wars",
			seriesName: "Darth Vader",
			individualComicName: "",
			yearFirstPublished: 2015,
			issueNumber: 1,
			totalPages: 23,
			eventName: "Darth Vader",
			purpose: "Darth Vader",
			dateRead: Date()
		)
		modelContext.insert(newComic)
		
		newComic = ComicData(
			brand: "Star Wars",
			seriesName: "Darth Vader",
			individualComicName: "",
			yearFirstPublished: 2015,
			issueNumber: 2,
			totalPages: 22,
			eventName: "Darth Vader",
			purpose: "Darth Vader",
			dateRead: Date()
		)
		modelContext.insert(newComic)
		
		newComic = ComicData(
			brand: "Star Wars",
			seriesName: "Darth Vader",
			individualComicName: "",
			yearFirstPublished: 2020,
			issueNumber: 1,
			totalPages: 22,
			eventName: "Darth Vader",
			purpose: "Darth Vader",
			dateRead: Date()
		)
		modelContext.insert(newComic)
		
		newComic = ComicData(
			brand: "FNAF",
			seriesName: "The Silver Eyes",
			individualComicName: "The Silver Eyes",
			yearFirstPublished: 2014,
			issueNumber: 1,
			totalPages: 356,
			eventName: "FNAF",
			purpose: "FNAF",
			dateRead: Date()
		)
		modelContext.insert(newComic)
		
		newComic = ComicData(
			brand: "FNAF",
			seriesName: "The Silver Eyes",
			individualComicName: "The Twisted Ones",
			yearFirstPublished: 2016,
			issueNumber: 2,
			totalPages: 301,
			eventName: "FNAF",
			purpose: "FNAF",
			dateRead: Date()
		)
		modelContext.insert(newComic)
		
		newComic = ComicData(
			brand: "FNAF",
			seriesName: "The Silver Eyes",
			individualComicName: "The Fourth Closet",
			yearFirstPublished: 2017,
			issueNumber: 3,
			totalPages: 362,
			eventName: "FNAF",
			purpose: "FNAF",
			dateRead: Date()
		)
		modelContext.insert(newComic)
		
		newComic = ComicData(
			brand: "Marvel",
			seriesName: "Deadpool & Wolverine: WWIII",
			individualComicName: "",
			yearFirstPublished: 2024,
			issueNumber: 1,
			totalPages: 29,
			eventName: "",
			purpose: "Deadpool",
			dateRead: Date()
		)
		modelContext.insert(newComic)
		
		// lastly save it
		try? modelContext.save()
		
		
		return ContentView()
			.environment(\.modelContext, modelContext)
			.environmentObject(GlobalState.shared)
	}
}

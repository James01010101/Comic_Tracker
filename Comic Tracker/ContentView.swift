//
//  ContentView.swift
//  Comic Tracker
//
//  Created by James Coldwell on 28/7/2024.
//

import SwiftUI
import SwiftData

struct ContentView: View {
	@Environment(\.modelContext) private var modelContext: ModelContext
	
	// this is used for all saving
	@StateObject private var persistenceController = PersistenceController.shared
	@StateObject private var globalState = GlobalState.shared

	
	// all of my apps views
	@State private var navigateToAddNewComicView: Bool = false
	
	
	// query variables (these are stored in the modelContext and are persistant)
	/// This will store all of my individual comic books data and should persist
	@Query(sort: \ComicData.readId, order: .reverse) private var comics: [ComicData]
	
	
	/// This is used to trigger the add new comic action sheet with options of new or continuing series
	@State private var showingAddNewActionSheet: Bool = false
		

	
	// Widths of each of the HStack elements for the comic to display
	private var readIdWidth: CGFloat = 45
	private var pagesWidth: CGFloat = 35
	
	
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
						.padding(.horizontal, 10)
			}
				
				// list stack
				List {
					// most recently read comics
					ForEach(comics) { comic in
						HStack {
							Text(String(comic.readId))
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
							} else {
								// default
								Label("Backup Data", systemImage: "square.and.arrow.down")
									
							}
						}
					}
					ToolbarItem(placement: .navigationBarTrailing) {
						EditButton()
					}
					ToolbarItem {
						Button(action: addItem) {
							Label("Add Comic", systemImage: "plus")
						}
					}
				}
				
				// when the add button is clicked show an action menu so you know to create a new or continuing series
				.actionSheet(isPresented: $showingAddNewActionSheet) {
					ActionSheet(
						title: Text("Add New Comic"),
						//message: Text("Choose an option"),
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
			.navigationDestination(isPresented: $navigateToAddNewComicView) {
				AddNewComicView()
			}
		}
	}
	
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
	
	
	// when adding a new comic an action sheet will show buttons which point to these 2 functions
	private func addNewComic() {
		navigateToAddNewComicView = true
	}
	
	private func addContinuingSeriesComic() {
		navigateToAddNewComicView = true
	}
	
	
	private func addItem() {
		showingAddNewActionSheet = true
	}
	
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
	
	private func addSomeTestingData() {
		// add some testing comics
		var newComic = ComicData(
			readId: 1,
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
			readId: 2,
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
			readId: 3,
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
			readId: 14,
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
			readId: 85,
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
			readId: 106,
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
			readId: 507,
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
			readId: 708,
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
			readId: 9999,
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
	}
}


// preview window settings
struct ContentView_Previews: PreviewProvider {
	static var previews: some View {
		let container = try! ModelContainer(
			for: ComicData.self,
			configurations: ModelConfiguration(isStoredInMemoryOnly: true)
		)
		
		let modelContext = ModelContext(container)
		
		// add some testing comics
		var newComic = ComicData(
			readId: 1,
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
			readId: 2,
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
			readId: 3,
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
			readId: 14,
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
			readId: 85,
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
			readId: 106,
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
			readId: 507,
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
			readId: 708,
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
			readId: 9999,
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

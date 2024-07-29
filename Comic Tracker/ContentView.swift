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
	
	// all of my apps views
	@State private var navigateToAddNewComicView: Bool = false
	
	
	// query variables (these are stored in the modelContext and are persistant)
	/// This will store all of my individual comic books data and should persist
	@Query private var comics: [ComicData]
	
	/// This will store all the general settings and stats i want relating to comics (There will only every be one of this)
	@Query private var generalComicStats: [GeneralComicStats]
	
	
	/// This is used to trigger the add new comic action sheet with options of new or continuing series
	@State private var showingAddNewActionSheet: Bool = false
	
	
	var body: some View {
		NavigationStack {
			List {
				ForEach(comics) { comic in
					Text("\(comic.readId)) \(comic.comicFullTitle) #\(comic.issueNumber)")
				}
				.onDelete(perform: deleteItems)
			}
			.toolbar {
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
			.navigationDestination(isPresented: $navigateToAddNewComicView) {
				AddNewComicView()
			}
		}
		.navigationTitle("Main Content View")
		.onAppear {
			initialiseGeneralComicStats()
		}
	}
	
	
	/// on load of the main view, create the GeneralComicStats object if it doesnt already exist (Only done once the first time the app is opened)
	private func initialiseGeneralComicStats() {
		// check if it already exists
		if (generalComicStats.count == 0) {
			// it does not exist so ill create it
			
			// first read id is 0 since itll be incremented before first use
			let newGeneralComicStats = GeneralComicStats(readId: 0)
			modelContext.insert(newGeneralComicStats)
			
			do {
				try modelContext.save()
			} catch {
				fatalError("Failed to save creation of GeneralComicStats, Exiting")
			}
			
			print("Created GeneralComicStats")
		}
	}
	
	
	// when adding a new comic an action sheet will show buttons which point to these 2 functions
	private func addNewComic() {
		navigateToAddNewComicView = true
	}
	
	private func addContinuingSeriesComic() {
		navigateToAddNewComicView = true
		let newSeriesComic = ComicData(
			readId: 5,
			comicFullTitle: "TEST SERIES",
			yearFirstPublished: 2001,
			issueNumber: 2,
			totalPages: 22,
			eventName: "Marvel",
			purpose: "Marvel"
		)
		modelContext.insert(newSeriesComic)
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
	}
}


// preview window settings
struct ContentView_Previews: PreviewProvider {
	static var previews: some View {
		ContentView()
			.modelContainer(for: [ComicData.self, GeneralComicStats.self], inMemory: true)
	}
}

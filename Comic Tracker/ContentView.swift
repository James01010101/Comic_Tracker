//
//  ContentView.swift
//  Comic Tracker
//
//  Created by James Coldwell on 28/7/2024.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
	
	// query variables
	/// This will store all of my individual comic books data and should persist
    @Query private var comics: [ComicData]
	
	
	/// this is used to trigger the add new comic action sheet with options of new or continuing series
	@State private var showingAddNewActionSheet: Bool = false

	
	
	

    var body: some View {
        NavigationSplitView {
            List {
                ForEach(comics) { comic in
					Text("\(comic.readId)) \(comic.comicFullTitle) #\(comic.issueNum)")
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
        } detail: {
            Text("Select an item")
        }
    }
	
	private func addNewComic() {
		withAnimation {
			let newComic = ComicData(readId: 1, 
									 comicFullTitle: "TEST",
									 yearFirstPublished: 2000,
									 issueNum: 1,
									 totalPages: 20,
									 eventName: "Marvel",
									 purpose: "Marvel")
			modelContext.insert(newComic)
		}
	}
	
	private func addContinuingSeriesComic() {
		withAnimation {
			let newSeriesComic = ComicData(readId: 5, 
										   comicFullTitle: "TEST SERIES",
										   yearFirstPublished: 2001,
										   issueNum: 2,
										   totalPages: 22,
										   eventName: "Marvel",
										   purpose: "Marvel")
			modelContext.insert(newSeriesComic)
		}
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

#Preview {
    ContentView()
        .modelContainer(for: ComicData.self, inMemory: true)
}

/*
 OLD EXAMPLE CODE
 import SwiftUI
 import SwiftData

 struct ContentView: View {
	 @Environment(\.modelContext) private var modelContext
	 @Query private var items: [Item]

	 var body: some View {
		 NavigationSplitView {
			 List {
				 ForEach(items) { item in
					 NavigationLink {
						 Text("Item at \(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))")
					 } label: {
						 Text(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))
					 }
				 }
				 .onDelete(perform: deleteItems)
			 }
			 .toolbar {
				 ToolbarItem(placement: .navigationBarTrailing) {
					 EditButton()
				 }
				 ToolbarItem {
					 Button(action: addItem) {
						 Label("Add Item", systemImage: "plus")
					 }
				 }
			 }
		 } detail: {
			 Text("Select an item")
		 }
	 }

	 private func addItem() {
		 withAnimation {
			 let newItem = Item(timestamp: Date())
			 modelContext.insert(newItem)
		 }
	 }

	 private func deleteItems(offsets: IndexSet) {
		 withAnimation {
			 for index in offsets {
				 modelContext.delete(items[index])
			 }
		 }
	 }
 }

 #Preview {
	 ContentView()
		 .modelContainer(for: Item.self, inMemory: true)
 }
 */

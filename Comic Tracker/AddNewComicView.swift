//
//  AddNewComicView.swift
//  Comic Tracker
//
//  Created by James Coldwell on 29/7/2024.
//

import Foundation
import SwiftUI
import SwiftData

/// View used for adding new comics to the ``ComicData`` array.
///
/// Part of this data can be auto filled if I am creating a new comic from an existing series.
struct AddNewComicView: View {
	/// Stores all of the data this view uses.
	/// > Important: Should be removed later and all data modifications should go through the ``PersistenceController``
	@Environment(\.modelContext) private var modelContext: ModelContext
	/// Enables me to return back to the calling view once i submit or cancel creating my new comic.
	@Environment(\.presentationMode) var presentationMode
	
	/// Controls all persistent data this view uses.
	@StateObject private var persistenceController = PersistenceController.shared
	/// Controls all global variables this view uses.
	@StateObject private var globalState = GlobalState.shared
	
	
	// query variables (these are stored in the modelContext and are persistant)
	/// Stores an array of ``ComicData`` which contains all of the individual comic books, which are stored in the ``PersistenceController``.
	@Query private var comics: [ComicData]
	/// Stores an array of ``ComicSeries`` which contains all of the individual comic series, which are stored in the ``PersistenceController``.
	@Query private var series: [ComicSeries]
	/// Stores an array of ``ComicEvent`` which contains all of the individual comic events, which are stored in the ``PersistenceController``.
	@Query private var events: [ComicEvent]
	
	// Values used by the form to store the input fields for the new comic being added.
	/// New unique id for this comic amongst the others in the ``ComicData`` array.
	///
	/// This will be the previous `comicId` + 1. This is not user given.
	@State private var readId: String = ""
	/// The brand of the comic, example "Marvel".
	@State private var brandName: String = ""
	/// The name of the series this comic is apart of.
	@State private var seriesName: String = ""
	/// The name of this specific comic, if it's different for every book in the series (Optional).
	@State private var individualComicName: String = ""
	/// The year the first book in this series was first published.
	///
	/// Needs a default value in the range as to not throw errors when initially loading the picker.
	@State private var yearFirstPublished: Int = 2000
	/// The issue number of this specific comic book.
	@State private var issueNumber: String = ""
	/// The total number of pages this comic book has.
	@State private var totalPages: String = ""
	/// The name of the event this comic is apart of (Optional).
	@State private var eventName: String = ""
	/// The reason I read this comic, could be for a character or story or event.
	@State private var purpose: String = ""
	/// The date I read this comic.
	@State private var dateRead: Date = Date()
	
	
	var body: some View {
		NavigationView {
			VStack {
				Form {
					Section(header: Text("Read ID")) {
						HStack {
							Image(systemName: "barcode")
							TextField("Read ID", text: $readId)
								.onAppear {
									self.readId = String(self.comics.count + 1)
								}
								.keyboardType(.phonePad)
						}
					}
					
					Section(header: Text("Books Brand")) {
						HStack {
							Image(systemName: "person.text.rectangle")
							TextField("Brand", text: $brandName)
						}
					}
					
					Section(header: Text("Series Name")) {
						HStack {
							Image(systemName: "books.vertical")
							TextField("Series Name", text: $seriesName)
						}
					}
					
					Section(header: Text("Individual Book Name (Optional)")) {
						HStack {
							Image(systemName: "text.book.closed")
							TextField("Individual Book's Name", text: $individualComicName)
						}
					}
					
					Section(header: Text("Issue Number")) {
						HStack {
							Image(systemName: "number.circle")
							TextField("Issue Number", text: $issueNumber)
								.keyboardType(.numberPad)
						}
					}
					
					Section(header: Text("Year First Published")) {
						HStack {
							Image(systemName: "calendar")
							Picker("Year First Published", selection: $yearFirstPublished) {
								ForEach(1800...2100, id: \.self) { year in
									Text(formattedNumber(number: year)).tag(year)
								}
							}
							.pickerStyle(MenuPickerStyle())
							.onAppear {
								self.yearFirstPublished = Calendar.current.component(.year, from: Date())
							}
						}
					}
					
					Section(header: Text("Total Pages")) {
						HStack {
							Image(systemName: "doc.plaintext")
							TextField("Total Pages", text: $totalPages)
								.keyboardType(.numberPad)
						}
					}
					
					Section(header: Text("Event Name")) {
						HStack {
							Image(systemName: "tag")
							TextField("Event Name", text: $eventName)
						}
					}
					
					Section(header: Text("Purpose")) {
						HStack {
							Image(systemName: "pencil")
							TextField("Purpose", text: $purpose)
						}
					}
					
					Section(header: Text("Date Read")) {
						HStack {
							Image(systemName: "calendar")
							DatePicker("Date Read", selection: $dateRead, displayedComponents: .date)
								.datePickerStyle(GraphicalDatePickerStyle())
						}
					}
					
					Section {
						Button(action: saveNewComic) {
							HStack {
								Spacer() // to center the save word in the middle of the HStack
								Text("Save")
									.bold()
								Spacer()
							}
						}
					}
				}
			}
			.navigationTitle("Save New Comics")
			.navigationBarTitleDisplayMode(.inline) // Use inline display mode to reduce vertical space
			.scrollDismissesKeyboard(.interactively)
		}
	}
	
	
	/// Used to format the numbers without commas in the year picker.
	/// 
	/// - Parameter number: input `Int` to format without comma's.
	/// - Returns: Formated `String` of an `Int` without comma's.
	private func formattedNumber(number: Int) -> String {
		let numberFormatter = NumberFormatter()
		numberFormatter.usesGroupingSeparator = false
		return numberFormatter.string(from: NSNumber(value: number)) ?? "\(number)"
	}
	
	
	/// Save the newly created comic to the modelContext.
	///
	/// This will also create a new ``ComicSeries`` and/or ``ComicEvent`` if it didnt exist before.
	/// It will add to the ``ComicSeries`` and/or ``ComicEvent`` if they exist.
	///
	/// Once successfully saved or canceled this will return back to the calling view, usually the main ``ContentView``.
	private func saveNewComic() {
		// call the saveComic function to save the new comic
		saveComic(
			brandName: brandName,
			seriesName: seriesName,
			individualComicName: individualComicName,
			yearFirstPublished: UInt16(self.yearFirstPublished),
			issueNumber: UInt16(issueNumber) ?? 0,
			totalPages: UInt16(totalPages) ?? 0,
			eventName: eventName,
			purpose: purpose,
			dateRead: Date(),
			modelContext: modelContext
		)
		
		// Autosave
		if (globalState.autoSave) {
			globalState.saveDataIcon = persistenceController.saveAllData()
		} else {
			// need to manually save because there have been changes
			globalState.saveDataIcon = nil
		}
		
		// Dismiss the view back to the main view
		presentationMode.wrappedValue.dismiss()
	}
}


/// The preview for the ``AddNewComicView``.
struct AddComicView_Previews: PreviewProvider {
	static var previews: some View {
		AddNewComicView()
			.modelContainer(for: [ComicData.self, ComicSeries.self, ComicEvent.self], inMemory: true)
	}
}

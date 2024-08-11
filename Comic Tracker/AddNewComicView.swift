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
	///
	/// This is sorted in decending order on the `comicId` to correctly be shown in  order in the list.
	@Query(sort: \ComicData.comicId, order: .reverse) private var comics: [ComicData]
	/// Stores an array of ``ComicSeries`` which contains all of the individual comic series, which are stored in the ``PersistenceController``.
	@Query private var series: [ComicSeries]
	/// Stores an array of ``ComicEvent`` which contains all of the individual comic events, which are stored in the ``PersistenceController``.
	@Query private var events: [ComicEvent]
	
	// Values used by the form to store the input fields for the new comic being added.
	/// The brand of the comic, example "Marvel".
	@State private var brandName: String
	/// The name of the series this comic is apart of.
	@State private var seriesName: String
	/// The name of this specific comic, if it's different for every book in the series (Optional).
	@State private var individualComicName: String
	/// The year the first book in this series was first published.
	@State private var yearFirstPublished: Int
	/// The issue number of this specific comic book.
	@State private var issueNumber: String
	/// The total number of pages this comic book has.
	@State private var totalPages: String
	/// The name of the event this comic is apart of (Optional).
	@State private var eventName: String
	/// The reason I read this comic, could be for a character or story or event.
	@State private var purpose: String
	/// The date I read this comic.
	@State private var dateRead: Date
	/// Known or unknown date, if false then date will be set to nil.
	@State private var dateKnown: Bool
	
	/// Is the form valid and able to be submitted (start blue, then if i click itll turn red if invalid).
	@State private var validForm: Bool = false
	
	
	/// The amount of spacing the icons get to keep it consistant
	private let iconWidth: CGFloat = 25
	private let leadingPadding: CGFloat = -10
	private let trailingTextPadding: CGFloat = 0
	
	
	
	
	// empty constructor for creating an empty view here
	init() {
		self.brandName = ""
		self.seriesName = ""
		self.individualComicName = ""
		self.yearFirstPublished = Calendar.current.component(.year, from: Date())
		self.issueNumber = ""
		self.totalPages = ""
		self.eventName = ""
		self.purpose = ""
		self.dateRead = Date()
		self.dateKnown = false // so the date section is hidden by default
	}
	
	
	
	/// constructor which takes in a series to auto fill information from
	init(series: ComicSeries) {
		self.brandName = series.seriesBrand
		self.seriesName = series.seriesTitle
		self.individualComicName = ""
		self.yearFirstPublished = Int(series.yearFirstPublished)
		self.dateRead = Date()
		self.dateKnown = false // so the date section is hidden by default
		
		// stats from recent comis
		self.issueNumber = String(series.recentComicIssueNumber + 1)
		self.totalPages = String(series.recentComicTotalPages)
		self.eventName = String(series.recentComicEventName)
		self.purpose = String(series.recentComicPurpose)
	}
	
	/// constructor which takes in a comic to auto fill information from
	init(comic: ComicData) {
		self.brandName = comic.brand
		self.seriesName = comic.seriesName
		self.individualComicName = ""
		self.yearFirstPublished = Int(comic.yearFirstPublished)
		self.dateRead = Date()
		self.dateKnown = false // so the date section is hidden by default
		
		// stats from recent comis
		self.issueNumber = String(comic.issueNumber + 1)
		self.totalPages = String(comic.totalPages)
		self.eventName = String(comic.eventName)
		self.purpose = String(comic.purpose)
	}
	
	
	
	var body: some View {
		NavigationStack {
			VStack {// headings stack
				VStack(spacing: 0) {
					HStack {
						Text("ID")
							.frame(width: 45, alignment: .center)
							.font(.headline)
							.padding(.leading, 10)
						
						Text("Series Name")
							.frame(maxWidth: .infinity, alignment: .center)
							.font(.headline)
							.padding(.leading, -10 - 45) // to adjust for the pages text being moved in slightly more
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
				
				List {
					HStack {
						Image(systemName: "person.text.rectangle")
							.frame(width: iconWidth, alignment: .center)
						
						Text("Brand")
							.font(.headline)
						
						TextEditor(text: $brandName)
							.multilineTextAlignment(.trailing)
							.padding(.bottom, -5)
							.padding(.trailing, trailingTextPadding)
						
					}
					.padding(.leading, leadingPadding)
					
					HStack {
						Image(systemName: "books.vertical")
							.frame(width: iconWidth, alignment: .center)
						
						Text("Series")
							.font(.headline)
						
						TextEditor(text: $seriesName)
							.multilineTextAlignment(.trailing)
							.padding(.bottom, -5)
							.padding(.trailing, trailingTextPadding)
						
					}
					.padding(.leading, leadingPadding)
					
					HStack {
						Image(systemName: "text.book.closed")
							.frame(width: iconWidth, alignment: .center)
						
						Text("Book?")
							.font(.headline)
						
						TextEditor(text: $individualComicName)
							.multilineTextAlignment(.trailing)
							.padding(.bottom, -5)
							.padding(.trailing, trailingTextPadding)
						
					}
					.padding(.leading, leadingPadding)
					
					HStack {
						Image(systemName: "number.circle")
							.frame(width: iconWidth, alignment: .center)
						
						Text("Issue")
							.font(.headline)
						
						TextField("", text: $issueNumber)
							.keyboardType(.numberPad)
							.multilineTextAlignment(.trailing)
							.padding(.trailing, trailingTextPadding)
						
					}
					.padding(.leading, leadingPadding)
					
					HStack {
						Image(systemName: "calendar")
							.frame(width: iconWidth, alignment: .center)
						
						Text("Year First Published")
							.font(.headline)
						
						Picker("", selection: $yearFirstPublished) {
							ForEach(1800...2100, id: \.self) { year in
								Text(formattedNumber(number: year)).tag(year)
							}
						}
						.pickerStyle(MenuPickerStyle())
					}
					.padding(.leading, leadingPadding)
					
					HStack {
						Image(systemName: "doc.plaintext")
							.frame(width: iconWidth, alignment: .center)
						
						Text("Pages")
							.font(.headline)
						
						TextField("", text: $totalPages)
							.keyboardType(.numberPad)
							.multilineTextAlignment(.trailing)
							.padding(.trailing, trailingTextPadding)
						
					}
					.padding(.leading, leadingPadding)
					
					HStack {
						Image(systemName: "tag")
							.frame(width: iconWidth, alignment: .center)
						
						Text("Event?")
							.font(.headline)
						
						TextEditor(text: $eventName)
							.multilineTextAlignment(.trailing)
							.padding(.bottom, -5)
							.padding(.trailing, trailingTextPadding)
					}
					.padding(.leading, leadingPadding)
					
					HStack {
						Image(systemName: "pencil")
							.frame(width: iconWidth, alignment: .center)
						
						Text("Purpose?")
							.font(.headline)
						
						TextEditor(text: $purpose)
							.multilineTextAlignment(.trailing)
							.padding(.bottom, -5)
							.padding(.trailing, trailingTextPadding)
					}
					.padding(.leading, leadingPadding)
					
					HStack {
						Image(systemName: "calendar")
							.frame(width: iconWidth, alignment: .center)
						
						Text("Date Read")
							.font(.headline)
						
						Toggle(isOn: $dateKnown) {}
					}
					.padding(.leading, leadingPadding)
					
					if (dateKnown) {
						HStack {
							DatePicker("Date Read", selection: $dateRead, displayedComponents: .date)
								.datePickerStyle(GraphicalDatePickerStyle())
						}
						.padding(.leading, leadingPadding)
					}
				}
				.padding([.leading, .trailing], -10)
				.listRowSpacing(8)
			}
			.navigationTitle("Save New Comics")
			.scrollDismissesKeyboard(.interactively)
			.toolbar {
				ToolbarItem {
					Button(action: {
						// check that the inputs are valid and if so save
						validForm = saveNewComicCheck()
						if (validForm) {
							saveNewComic()
						}
					}) {
						if (validForm) {
							Text("Save")
								.bold()
								.tint(.blue)
						} else {
							Text("Save")
								.bold()
								.tint(.red)
						}
					}
				}
			}
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
	
	
	/// before actually saving the new comic check that all required input fields are valid
	private func saveNewComicCheck() -> Bool {
		// check brand
		var brandCheck = false
		var seriesCheck = false
		var issueCheck = false
		var pagesCheck = false
		
		// brand is not empty
		if (!brandName.isEmpty) {
			brandCheck = true
		}
		
		// series is not empty
		if (!seriesName.isEmpty) {
			seriesCheck = true
		}
		
		// issue is not empty and is >= 0 (not negative)
		if (!issueNumber.isEmpty) {
			if let issue = Int(issueNumber) {
				if (issue >= 0) {
					issueCheck = true
				}
			}
		}
		
		// total pages is not empty and is >= 0 (not negative)
		if (!totalPages.isEmpty) {
			if let pages = Int(totalPages) {
				if (pages >= 0) {
					pagesCheck = true
				}
			}
		}
		
		
		// return true only if all checks are true
		if (brandCheck && seriesCheck && issueCheck && pagesCheck) {
			return true
		} else {
			return false
		}
	}
	
	
	/// Save the newly created comic to the modelContext.
	///
	/// This will also create a new ``ComicSeries`` and/or ``ComicEvent`` if it didnt exist before.
	/// It will add to the ``ComicSeries`` and/or ``ComicEvent`` if they exist.
	///
	/// Once successfully saved or canceled this will return back to the calling view, usually the main ``ContentView``.
	private func saveNewComic() {
		
		// work out the date if it is nil or not
		let date: Date?
		if (!dateKnown) {
			date = nil
		} else {
			date = dateRead
		}
		
		// call the saveComic function to save the new comic
		saveComic(
			brandName: brandName,
			seriesName: seriesName,
			individualComicName: individualComicName,
			yearFirstPublished: UInt16(yearFirstPublished),
			issueNumber: UInt16(issueNumber) ?? 0,
			totalPages: UInt16(totalPages) ?? 0,
			eventName: eventName,
			purpose: purpose,
			dateRead: date,
			modelContext: modelContext
		)


		// Autosave
		if (globalState.autoSave) {
			globalState.saveDataIcon = persistenceController.saveAllData()
		} else {
			// need to manually save because there have been changes
			globalState.saveDataIcon = nil
		}
		
		// lastly set the saved comic to
		
		// Dismiss the view back to the main view
		presentationMode.wrappedValue.dismiss()
	}
}


/// The preview for the ``AddNewComicView``.
struct AddComicView_Previews: PreviewProvider {
	static var previews: some View {
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
		
		
		
		// add some testing comics
		saveComic(
			brandName: "Marvel",
			seriesName: "Infinity Gauntlet",
			individualComicName: "",
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
			seriesName: "Infinity Gauntlet",
			individualComicName: "",
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
			seriesName: "Darth Vader",
			individualComicName: "",
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
			seriesName: "Darth Vader",
			individualComicName: "",
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
			seriesName: "Darth Vader",
			individualComicName: "",
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
			seriesName: "The Silver Eyes",
			individualComicName: "The Silver Eyes",
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
			seriesName: "The Silver Eyes",
			individualComicName: "The Twisted Ones",
			yearFirstPublished: 2014,
			issueNumber: 2,
			totalPages: 301,
			eventName: "FNAF",
			purpose: "FNAF",
			dateRead: nil,
			modelContext: context
		)
		
		saveComic(
			brandName: "FNAF",
			seriesName: "The Silver Eyes",
			individualComicName: "The Fourth Closet",
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
			seriesName: "Deadpool & Wolverine: WWIII",
			individualComicName: "",
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
			seriesName: "The Walking Dead",
			individualComicName: "",
			yearFirstPublished: 2020,
			issueNumber: 1,
			totalPages: 30,
			eventName: "",
			purpose: "The Walking Dead",
			dateRead: nil,
			modelContext: context
		)
		
		saveComic(
			brandName: "The Walking Dead",
			seriesName: "The Walking Dead",
			individualComicName: "",
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
		
		
		return AddNewComicView()
			.environment(\.modelContext, context)
			.environmentObject(GlobalState.shared)
	}
}

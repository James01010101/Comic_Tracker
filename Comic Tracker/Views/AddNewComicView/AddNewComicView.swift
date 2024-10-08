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
	/// The shorthand brand of the comic, example "TWD".
	@State private var shortBrandName: String
	/// The prioties shorthand even if it isnt needed
	@State private var prioritizeShortBrandName: Bool
	/// Lock the brand toggle so it cant be changed
	@State private var lockBrandToggle: Bool = false
	
	/// The name of the series this comic is apart of.
	@State private var seriesName: String
	/// The shorthand series of the comic, example "JJK".
	@State private var shortSeriesName: String
	/// The prioties shorthand even if it isnt needed
	@State private var prioritizeShortSeriesName: Bool
	
	/// The name of this specific comic, if it's different for every book in the series (Optional).
	@State private var comicName: String
	/// The shorthand comic name, example "JJK".
	@State private var shortComicName: String
	/// The prioties shorthand even if it isnt needed
	@State private var prioritizeShortComicName: Bool
	
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
	
	/// The Url for this comic to the marvel ultimate app,
	@State private var marvelUltimateLink: String
	/// An enum representing if ive read this comic or not
	@State private var comicRead: ComicReadEnum
	
	/// Is the form valid and able to be submitted (start blue, then if i click itll turn red if invalid).
	@State private var validForm: Bool = true
	
	/// when creating a comic from a series i can hide the top input fields to allow more space for other fields
	@State private var hideTopInputs: Bool = true
	
	
	/// The amount of spacing the icons get to keep it consistant
	private let iconWidth: CGFloat = 25
	private let leadingPadding: CGFloat = -10
	private let trailingTextPadding: CGFloat = 0
	
	
	// empty constructor for creating an empty view here
	init() {
		self.brandName = ""
		self.shortBrandName = ""
		self.prioritizeShortBrandName = false
		
		self.seriesName = ""
		self.shortSeriesName = ""
		self.prioritizeShortSeriesName = false
		
		self.comicName = ""
		self.shortComicName = ""
		self.prioritizeShortComicName = false
		
		self.yearFirstPublished = Calendar.current.component(.year, from: Date())
		self.issueNumber = ""
		self.totalPages = ""
		self.eventName = ""
		self.purpose = ""
		self.dateRead = Date()
		self.dateKnown = true
		
		self.marvelUltimateLink = ""
		self.comicRead = ComicReadEnum.Read
	}
	
	/// constructor which takes in a series to auto fill information from
	init(series: ComicSeries) {
		self.brandName = series.brandName
		self.shortBrandName = series.shortBrandName
		self.prioritizeShortBrandName = series.prioritizeShortBrandName
		
		self.seriesName = series.seriesName
		self.shortSeriesName = series.shortSeriesName
		self.prioritizeShortSeriesName = series.prioritizeShortSeriesName
		
		self.comicName = ""
		self.shortComicName = ""
		self.prioritizeShortComicName = false
		
		self.yearFirstPublished = Int(series.yearFirstPublished)
		self.dateRead = Date()
		self.dateKnown = true
		
		// stats from recent comis
		self.issueNumber = String(series.recentComicIssueNumber + 1)
		self.totalPages = String(series.recentComicTotalPages)
		self.eventName = String(series.recentComicEventName)
		self.purpose = String(series.recentComicPurpose)
		
		self.marvelUltimateLink = ""
		self.comicRead = ComicReadEnum.Read
	}
	
	/// constructor which takes in a comic to auto fill information from
	init(comic: ComicData) {
		self.brandName = comic.brandName
		self.shortBrandName = comic.shortBrandName
		self.prioritizeShortBrandName = comic.prioritizeShortBrandName
		
		self.seriesName = comic.seriesName
		self.shortSeriesName = comic.shortSeriesName
		self.prioritizeShortSeriesName = comic.prioritizeShortSeriesName
		
		self.comicName = comic.comicName
		self.shortComicName = comic.shortComicName
		self.prioritizeShortComicName = comic.prioritizeShortComicName
		
		self.yearFirstPublished = Int(comic.yearFirstPublished)
		self.dateRead = Date()
		self.dateKnown = true
		
		// stats from recent comis
		self.issueNumber = String(comic.issueNumber + 1)
		self.totalPages = String(comic.totalPages)
		self.eventName = String(comic.eventName)
		self.purpose = String(comic.purpose)
		
		self.marvelUltimateLink = ""
		self.comicRead = ComicReadEnum.Read
	}
	
	
	var body: some View {
		NavigationStack {
			VStack {
				// headings stack
				VStack(spacing: 0) {
					HStack {
						Text("Input New Comic Information")
							.frame(maxWidth: .infinity, alignment: .center)
							.font(.headline)
					}
					.padding(.top, 10)
					.padding(.bottom, -5)
					
					// Divider
					Rectangle()
						.frame(height: 3) // Adjust the height for a bolder line
						.padding(.top, 10) // Optional: Add some padding below the divider
						.padding(.horizontal, 10) // insert the boarder line slightly from the edges of the screen
				}
				
				// main options
				List {
					if (!hideTopInputs) {
						// Brand section
						BrandInputsView(
							iconWidth: iconWidth,
							leadingPadding: leadingPadding,
							trailingTextPadding: trailingTextPadding,
							
							brandName: $brandName,
							shortBrandName: $shortBrandName,
							prioritizeShortBrandName: $prioritizeShortBrandName
						)
						
						// Series section
						SeriesInputsView(
							iconWidth: iconWidth,
							leadingPadding: leadingPadding,
							trailingTextPadding: trailingTextPadding,
							
							seriesName: $seriesName,
							shortSeriesName: $shortSeriesName,
							prioritizeShortSeriesName: $prioritizeShortSeriesName
						)
						
						// Book section
						BookInputsView(
							iconWidth: iconWidth,
							leadingPadding: leadingPadding,
							trailingTextPadding: trailingTextPadding,
							
							comicName: $comicName,
							shortComicName: $shortComicName,
							prioritizeShortComicName: $prioritizeShortComicName
						)
						
						// Year first published
						YearInputView(
							iconWidth: iconWidth,
							leadingPadding: leadingPadding,
							trailingTextPadding: trailingTextPadding,
							yearFirstPublished: $yearFirstPublished
						)
						
						// Event
						EventInputView(
							iconWidth: iconWidth,
							leadingPadding: leadingPadding,
							trailingTextPadding: trailingTextPadding,
							eventName: $eventName
						)
						
						// Purpose
						PurposeInputView(
							iconWidth: iconWidth,
							leadingPadding: leadingPadding,
							trailingTextPadding: trailingTextPadding,
							purpose: $purpose
						)
					} else {
						// if i am hiding them then instead i want to show the comics bubble
						CondensedComicView(
							brandName: $brandName,
							shortBrandName: $shortBrandName,
							prioritizeShortBrandName: $prioritizeShortBrandName,
							
							seriesName: $seriesName,
							shortSeriesName: $shortSeriesName,
							prioritizeShortSeriesName: $prioritizeShortSeriesName,
							
							comicName: $comicName,
							shortComicName: $shortComicName,
							prioritizeShortComicName: $prioritizeShortComicName,
							
							yearFirstPublished: $yearFirstPublished,
							issueNumber: $issueNumber,
							totalPages: $totalPages
						);
					}
					
					// Issue
					IssueInputView(
						iconWidth: iconWidth,
						leadingPadding: leadingPadding,
						trailingTextPadding: trailingTextPadding,
						issueNumber: $issueNumber
					);
					
					// Pages read
					PagesInputView(
						iconWidth: iconWidth,
						leadingPadding: leadingPadding,
						trailingTextPadding: trailingTextPadding,
						totalPages: $totalPages
					);
					
					// Marvel Comics Link
					LinkInputView(
						iconWidth: iconWidth,
						leadingPadding: leadingPadding,
						trailingTextPadding: trailingTextPadding,
						marvelUltimateLink: $marvelUltimateLink
					);
					
					// Date read section
					DateInputView(
						iconWidth: iconWidth,
						leadingPadding: leadingPadding,
						trailingTextPadding: trailingTextPadding,
						
						comicRead: $comicRead,
						dateKnown: $dateKnown,
						dateRead: $dateRead
					)
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
	
	/// before actually saving the new comic check that all required input fields are valid
	private func saveNewComicCheck() -> Bool {
		// check brand
		var brandCheck = false
		var seriesCheck = false
		var comicCheck = false
		var issueCheck = false
		var pagesCheck = false
		
		// brand is not empty
		if (!brandName.isEmpty) {
			// check if the string is over max length
			if (brandName.count > globalState.maxDisplayedStringLength) {
				// requires shortend string
				if (prioritizeShortBrandName && !shortBrandName.isEmpty && shortBrandName.count < globalState.maxDisplayedStringLength) {
					brandCheck = true
				}
				// if the string isnt over max length then its good
			} else {
				brandCheck = true
			}
		}
		
		// series is not empty
		if (!seriesName.isEmpty) {
			// check if the string is over max length
			if (seriesName.count > globalState.maxDisplayedStringLength) {
				// requires shortend string
				if (prioritizeShortSeriesName && !shortSeriesName.isEmpty && shortSeriesName.count < globalState.maxDisplayedStringLength) {
					seriesCheck = true
				}
				// if the string isnt over max length then its good
			} else {
				seriesCheck = true
			}
		}
		
		// comic check (can be empty)
		if (!comicName.isEmpty) {
			// check if the string is over max length
			if (comicName.count > globalState.maxDisplayedStringLength) {
				// requires shortend string
				if (prioritizeShortComicName && !shortComicName.isEmpty && shortComicName.count < globalState.maxDisplayedStringLength) {
					comicCheck = true
				}
				// if the string isnt over max length then its good
			} else {
				comicCheck = true
			}
		} else { // if its empty thats fine
			comicCheck = true
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
		if (brandCheck && seriesCheck && comicCheck && issueCheck && pagesCheck) {
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
		// trim whitespace off the starts and ends of strings
		saveComic(
			brandName: brandName.trimmingCharacters(in: .whitespacesAndNewlines),
			shortBrandName: shortBrandName.trimmingCharacters(in: .whitespacesAndNewlines),
			prioritizeShortBrandName: prioritizeShortBrandName,
			
			seriesName: seriesName.trimmingCharacters(in: .whitespacesAndNewlines),
			shortSeriesName: shortSeriesName.trimmingCharacters(in: .whitespacesAndNewlines),
			prioritizeShortSeriesName: prioritizeShortSeriesName,
			
			comicName: comicName.trimmingCharacters(in: .whitespacesAndNewlines),
			shortComicName: shortComicName.trimmingCharacters(in: .whitespacesAndNewlines),
			prioritizeShortComicName: prioritizeShortComicName,
			
			yearFirstPublished: UInt16(yearFirstPublished),
			issueNumber: UInt16(issueNumber) ?? 0,
			totalPages: UInt16(totalPages) ?? 0,
			eventName: eventName.trimmingCharacters(in: .whitespacesAndNewlines),
			purpose: purpose.trimmingCharacters(in: .whitespacesAndNewlines),
			dateRead: date,
			modelContext: modelContext,
			
			marvelUltimateLink: marvelUltimateLink.trimmingCharacters(in: .whitespacesAndNewlines),
			comicRead: comicRead
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
		
		
		return AddNewComicView()
			.environment(\.modelContext, context)
	}
}

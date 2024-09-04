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
	/// Lock the series toggle so it cant be changed
	@State private var lockSeriesToggle: Bool = false
	
	/// The name of this specific comic, if it's different for every book in the series (Optional).
	@State private var comicName: String
	/// The shorthand comic name, example "JJK".
	@State private var shortComicName: String
	/// The prioties shorthand even if it isnt needed
	@State private var prioritizeShortComicName: Bool
	/// Lock the comic toggle so it cant be changed
	@State private var lockComicToggle: Bool = false
	
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
		self.dateKnown = false // so the date section is hidden by default
		
		self.marvelUltimateLink = ""
		self.comicRead = ComicReadEnum.NotRead
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
		self.dateKnown = false // so the date section is hidden by default
		
		// stats from recent comis
		self.issueNumber = String(series.recentComicIssueNumber + 1)
		self.totalPages = String(series.recentComicTotalPages)
		self.eventName = String(series.recentComicEventName)
		self.purpose = String(series.recentComicPurpose)
		
		self.marvelUltimateLink = ""
		self.comicRead = ComicReadEnum.NotRead
	}
	
	/// constructor which takes in a comic to auto fill information from
	init(comic: ComicData) {
		self.brandName = comic.brandName
		self.shortBrandName = comic.shortBrandName
		self.prioritizeShortBrandName = comic.prioritizeShortBrandName
		
		self.seriesName = comic.seriesName
		self.shortSeriesName = comic.shortSeriesName
		self.prioritizeShortSeriesName = comic.prioritizeShortSeriesName
		
		self.comicName = ""
		self.shortComicName = ""
		self.prioritizeShortComicName = false
		
		self.yearFirstPublished = Int(comic.yearFirstPublished)
		self.dateRead = Date()
		self.dateKnown = false // so the date section is hidden by default
		
		// stats from recent comis
		self.issueNumber = String(comic.issueNumber + 1)
		self.totalPages = String(comic.totalPages)
		self.eventName = String(comic.eventName)
		self.purpose = String(comic.purpose)
		
		self.marvelUltimateLink = ""
		self.comicRead = ComicReadEnum.NotRead
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
					// Brand section
					VStack {
						HStack {
							Image(systemName: "person.text.rectangle")
								.frame(width: iconWidth, alignment: .center)
							
							Text("Brand")
								.font(.headline)
							
							TextEditor(text: $brandName)
								.onChange(of: brandName) {
									// if the text is over the max length
									if (brandName.count > globalState.maxDisplayedStringLength && !lockBrandToggle) {
										// lock the toggle on
										prioritizeShortBrandName = true
										lockBrandToggle = true
										
										// if the text goes under max length but was still locked unlock it
									} else if (brandName.count < globalState.maxDisplayedStringLength && lockBrandToggle) {
										lockBrandToggle = false
										
										// dont toggle the short off though unless its empty
										// if not empty leave it on
										if (shortBrandName.isEmpty) {
											prioritizeShortBrandName = false
										}
									}
								}
								.multilineTextAlignment(.trailing)
								.padding(.bottom, -5)
								.padding(.trailing, trailingTextPadding)
							
						}
						.padding(.leading, leadingPadding)
						
						HStack {
							Image(systemName: "person.text.rectangle")
								.frame(width: iconWidth, alignment: .center)
							
							Text("Short Brand?")
								.font(.headline)
							
							TextEditor(text: $shortBrandName)
								.onChange(of: shortBrandName) {
									// if the string is empty toggle it back to off
									if (shortBrandName.count == 0 && !lockBrandToggle) {
										prioritizeShortBrandName = false
									}
								}
								.multilineTextAlignment(.trailing)
								.padding(.bottom, -5)
								.padding(.trailing, trailingTextPadding)
						}
						.padding(.leading, leadingPadding)
						
						if (!shortBrandName.isEmpty || prioritizeShortBrandName) {
							HStack {
								Image(systemName: "person.text.rectangle")
									.frame(width: iconWidth, alignment: .center)
								
								Text("Prioritize Short")
									.font(.headline)
								
								Toggle("", isOn: $prioritizeShortBrandName)
									.disabled(lockBrandToggle)
								
							}
							.padding(.leading, leadingPadding)
						}
					}
					
					// Series section
					VStack {
						HStack {
							Image(systemName: "books.vertical")
								.frame(width: iconWidth, alignment: .center)
							
							Text("Series")
								.font(.headline)
							
							TextEditor(text: $seriesName)
								.onChange(of: seriesName) {
									// if the text is over the max length
									if (seriesName.count > globalState.maxDisplayedStringLength && !lockSeriesToggle) {
										// lock the toggle on
										prioritizeShortSeriesName = true
										lockSeriesToggle = true
										
										// if the text goes under max length but was still locked unlock it
									} else if (seriesName.count < globalState.maxDisplayedStringLength && lockSeriesToggle) {
										lockSeriesToggle = false
										
										// dont toggle the short off though unless its empty
										// if not empty leave it on
										if (shortSeriesName.isEmpty) {
											prioritizeShortSeriesName = false
										}
									}
								}
								.multilineTextAlignment(.trailing)
								.padding(.bottom, -5)
								.padding(.trailing, trailingTextPadding)
							
						}
						.padding(.leading, leadingPadding)
						
						HStack {
							Image(systemName: "books.vertical")
								.frame(width: iconWidth, alignment: .center)
							
							Text("Short Series?")
								.font(.headline)
							
							TextEditor(text: $shortSeriesName)
								.onChange(of: shortSeriesName) {
									// if the string is empty toggle it back to off
									if (shortSeriesName.count == 0 && !lockSeriesToggle) {
										prioritizeShortSeriesName = false
									}
								}
								.multilineTextAlignment(.trailing)
								.padding(.bottom, -5)
								.padding(.trailing, trailingTextPadding)
						}
						.padding(.leading, leadingPadding)
						
						if (!shortSeriesName.isEmpty || prioritizeShortSeriesName) {
							HStack {
								Image(systemName: "books.vertical")
									.frame(width: iconWidth, alignment: .center)
								
								Text("Prioritize Short")
									.font(.headline)
								
								Toggle("", isOn: $prioritizeShortSeriesName)
									.disabled(lockSeriesToggle)
							}
							.padding(.leading, leadingPadding)
						}
					}
					
					// Book section
					VStack {
						HStack {
							Image(systemName: "text.book.closed")
								.frame(width: iconWidth, alignment: .center)
							
							Text("Book?")
								.font(.headline)
							
							TextEditor(text: $comicName)
								.onChange(of: comicName) {
									// if the text is over the max length
									if (comicName.count > globalState.maxDisplayedStringLength && !lockComicToggle) {
										// lock the toggle on
										prioritizeShortComicName = true
										lockComicToggle = true
										
										// if the text goes under max length but was still locked unlock it
									} else if (comicName.count < globalState.maxDisplayedStringLength && lockComicToggle) {
										lockComicToggle = false
										
										// dont toggle the short off though unless its empty
										// if not empty leave it on
										if (shortComicName.isEmpty) {
											prioritizeShortComicName = false
										}
									}
								}
								.multilineTextAlignment(.trailing)
								.padding(.bottom, -5)
								.padding(.trailing, trailingTextPadding)
							
						}
						.padding(.leading, leadingPadding)
						
						HStack {
							Image(systemName: "text.book.closed")
								.frame(width: iconWidth, alignment: .center)
							
							Text("Short Book Name?")
								.font(.headline)
							
							TextEditor(text: $shortComicName)
								.onChange(of: shortComicName) {
									// if the string is empty toggle it back to off
									if (shortComicName.count == 0 && !lockComicToggle) {
										prioritizeShortComicName = false
									}
								}
								.multilineTextAlignment(.trailing)
								.padding(.bottom, -5)
								.padding(.trailing, trailingTextPadding)
						}
						.padding(.leading, leadingPadding)
						
						if (!shortComicName.isEmpty || prioritizeShortComicName) {
							HStack {
								Image(systemName: "text.book.closed")
									.frame(width: iconWidth, alignment: .center)
								
								Text("Prioritize Short")
									.font(.headline)
								
								Toggle("", isOn: $prioritizeShortComicName)
									.disabled(lockComicToggle)
							}
							.padding(.leading, leadingPadding)
						}
					}
					
					// Issue
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
					
					// Year first published
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
					
					// Pages read
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
					
					// Event
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
					
					// Purpose
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
					
					// Marvel Comics Link
					HStack {
						Image(systemName: "link")
							.frame(width: iconWidth, alignment: .center)
						
						Text("Marvel Universe Link?")
							.font(.headline)
						
						TextEditor(text: $marvelUltimateLink)
							.multilineTextAlignment(.trailing)
							.padding(.bottom, -5)
							.padding(.trailing, trailingTextPadding)
					}
					.padding(.leading, leadingPadding)
					
					// Date read section
					VStack {
						VStack {
							Text("Select Comic Read Status")
								.font(.headline)
							
							Picker("Comic Read Status", selection: $comicRead) {
								ForEach(ComicReadEnum.allCases) { state in
									Text(state.rawValue).tag(state)
								}
								
							}
							.pickerStyle(SegmentedPickerStyle())
							.onChange(of: comicRead) {
								// if i change it back to not read or skipped i dont wasnt to save the date anymore so both the date variables need to go back to defaults
								if (comicRead == ComicReadEnum.NotRead || comicRead == ComicReadEnum.Skipped) {
									dateKnown = false
									// dateRead will be set to nil if dateKnown in false in the save function below
								}
							}
						}
						.padding(.bottom, 5)
						
						if (comicRead == ComicReadEnum.Read) {
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
		saveComic(
			brandName: brandName,
			shortBrandName: shortBrandName,
			prioritizeShortBrandName: prioritizeShortBrandName,
			
			seriesName: seriesName,
			shortSeriesName: shortSeriesName,
			prioritizeShortSeriesName: prioritizeShortSeriesName,
			
			comicName: comicName,
			shortComicName: shortComicName,
			prioritizeShortComicName: prioritizeShortComicName,
			
			yearFirstPublished: UInt16(yearFirstPublished),
			issueNumber: UInt16(issueNumber) ?? 0,
			totalPages: UInt16(totalPages) ?? 0,
			eventName: eventName,
			purpose: purpose,
			dateRead: date,
			modelContext: modelContext,
			
			marvelUltimateLink: marvelUltimateLink,
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

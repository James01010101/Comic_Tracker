//
//  EventsStatsView.swift
//  Comic Tracker
//
//  Created by James Coldwell on 10/8/2024.
//

import Foundation
import SwiftUI
import SwiftData

/// This contains a list of all of the events I have with a bunch of statistics for each event
struct EventsStatsView: View {
	
	/// Controls all persistent data this view uses.
	@StateObject private var persistenceController = PersistenceController.shared
	/// Controls all global variables this view uses.
	@StateObject private var globalState = GlobalState.shared
	
	
	/// Stores an array of ``ComicEvent`` which contains all of the individual comic events, which are stored in the ``PersistenceController``.
	@Query private var events: [ComicEvent]
	
	/// Go to an edit view for the event, this is how you would add reading lists
	@State private var showSheet: Bool = false
	
	/// Selected event to be stored to be used later
	@State private var selectedEvent: ComicEvent?
	
	
	/// Width of the `readId` element in the list
	///
	/// Used to get nice spacing and to allow the comic name to have the most space possible
	private let readIdWidth: CGFloat = 45
	
	// top section
	private let eventsIdLeadingPadding: CGFloat = -12
	
	// bottom section
	private let statMajorWidth: CGFloat = 75
	private let statMajorTopPadding: CGFloat = -15
	private let majorDividerBottomPadding: CGFloat = 10
	private let issuesStatsTopPadding: CGFloat = -5
	private let minorIssuesVerticalDividerPaddingTop: CGFloat = 8
	private let minorIssuesVerticalDividerPaddingBottom: CGFloat = 10
	
	
	// main view body
	var body: some View {
		NavigationStack {
			VStack {
				// headings stack
				VStack(spacing: 0) {
					HStack {
						Text("ID")
							.frame(width: readIdWidth, alignment: .center)
							.font(.headline)
							.padding(.leading, 10)
						
						Text("Event Name")
							.frame(maxWidth: .infinity, alignment: .center)
							.font(.headline)
							.padding(.leading, -10 - readIdWidth) // to adjust for the pages text being moved in slightly more
							.padding(.trailing, 10)
					}
					.padding(.top, 10)
					.padding(.bottom, -5)
					
					// Divider
					Rectangle()
						.frame(height: 3) // Adjust the height for a bolder line
						.padding(.top, 10) // Optional: Add some padding below the divider
						.padding(.horizontal, 10) // insert the boarder line slightly from the edges of the screen
				}
				
				// VStack list for all the series
				// the series will take up to lines each
				// one for the series, and one for stats
				List {
					ForEach(events) { event in
						// this row
						VStack {
							// top row name
							HStack {
								Text(String(event.eventId))
									.frame(width: 25, alignment: .center)
									.padding(.leading, eventsIdLeadingPadding)
									.modifier(MainDisplayTextStyle(globalState: globalState))
								
								Divider()
									.padding(.top, 1)
								
								Text(getEventsFormattedName(event: event))
									// force it to take up all the space so the id gets forced to the left
									.frame(maxWidth: .infinity)
									// remove as much padding from either side to give it as much space as possible (it is centered so normally you wont tell anyway)
									.padding(.leading, -5)
									.padding(.trailing, -15)
									.modifier(MainDisplayTextStyle(globalState: globalState))
							}
							.frame(height: 25)
							.padding(.bottom, -3)
							
							Divider()
								.padding([.leading, .trailing], -10) // extend the sides of the divider
							
							// bottom row stats
							HStack {
								
								VStack {
									Text("Issues")
										.padding([.top, .bottom], -6)
										.modifier(MainDisplayTextStyle(globalState: globalState))
									
									Divider()
									
									HStack {
										VStack {
											Text("Total")
												.modifier(MainDisplayTextStyle(globalState: globalState))
											Text(String(event.totalIssues))
												.frame(maxWidth: .infinity)
												.modifier(MainDisplayTextStyle(globalState: globalState))
										}
										.padding(.top, issuesStatsTopPadding)
										
										Divider()
											.padding(.top, minorIssuesVerticalDividerPaddingTop)
											.padding(.bottom, minorIssuesVerticalDividerPaddingBottom)
										
										VStack {
											Text("Read")
												.modifier(MainDisplayTextStyle(globalState: globalState))
											Text(String(event.issuesRead))
												.frame(maxWidth: .infinity)
												.modifier(MainDisplayTextStyle(globalState: globalState))
										}
										.padding(.top, issuesStatsTopPadding)
										
										Divider()
											.padding(.top, minorIssuesVerticalDividerPaddingTop)
											.padding(.bottom, minorIssuesVerticalDividerPaddingBottom)
										
										VStack {
											Text("Left")
												.modifier(MainDisplayTextStyle(globalState: globalState))
											Text(getIssuesLeft(event: event))
												.frame(maxWidth: .infinity)
												.modifier(MainDisplayTextStyle(globalState: globalState))
										}
										.padding(.top, issuesStatsTopPadding)
									}
									.padding(.top, -8)
								}
								
								Divider()
									.padding(.bottom, majorDividerBottomPadding)
								
								VStack {
									Text("Pages")
										.modifier(MainDisplayTextStyle(globalState: globalState))
									Text(String(event.pagesRead))
										.frame(width: statMajorWidth)
										.modifier(MainDisplayTextStyle(globalState: globalState))
								}
								.padding(.top, statMajorTopPadding)
							}
							.frame(maxWidth: .infinity, alignment: .center)
							.padding([.leading, .trailing], -15)
							.padding(.bottom, -8)
						}
						.onTapGesture {
							selectedEvent = event
							showSheet = true
						}
						.listRowBackground(globalState.getBrandColor(brandName: event.brandName))
					}
					.onDelete(perform: deleteItems)
				}
				// less padding either side of the list
				.padding(.leading, -10)
				.padding(.trailing, -10)
				.listRowSpacing(8)
			}
			.alert("Toggle Shorthand Brand", isPresented: $showSheet) {
				if let event = selectedEvent {
					if (!event.shortBrandName.isEmpty) {
						
						Button("Turn Short " + (event.prioritizeShortBrandName ? "Off" : "On"), action: {
							event.prioritizeShortBrandName.toggle()
							// autosave
							if (globalState.autoSave) {
								globalState.saveDataIcon = persistenceController.saveAllData()
							} else {
								// need to manually because there have been changes
								globalState.saveDataIcon = nil
							}
							
							showSheet = false
						})
					}
				}
				Button("Cancel", action: {
					showSheet = false
				})
			} message: {
				if let event = selectedEvent {
					if (event.prioritizeShortBrandName) {
						Text("Shorthand Is ON")
					} else {
						Text("Shorthand Is OFF")
					}
				}
			}
			.navigationTitle("Comic Events")
		}
	}
	
	
	/// Takes a event and returns a nicely formatted string to represent it.
	/// - Parameter series: ``ComicEvent`` which contains all the information about the event.
	/// - Returns: Formatted `String` representing the event.
	private func getEventsFormattedName(event: ComicEvent) -> String {
		var formattedString: String = ""
		
		formattedString = event.prioritizeShortBrandName ? event.shortBrandName : event.brandName
		formattedString += ": " + event.eventName
		
		return formattedString
	}
	
	
	
	/// Get the number of issues left to read in this event.
	///
	/// This is done as a function because the values are UInt and i am subtracting it the app can crash if i underflow without catching that.
	///
	/// - Parameter series: A ``ComicEvent`` containing all the information about the event.
	/// - Returns: `String` which is the number of issues left to read, or 0 if failed.
	private func getIssuesLeft(event: ComicEvent) -> String {
		let read: UInt16 = event.issuesRead
		let total: UInt16 = event.totalIssues
		var left: Int = 0
		
		// I haven't set the total yet
		if (total == 0) {
			return "0"
		}
		else {
			// convert to int first, if i have read more than i have set as total itll be negative
			// if they stay as UInt then it will break and crash
			// so set to Int, if the result is negative then ive read than many more books than the total
			left = Int(total) - Int(read)
			return String(left)
		}
	}
	
	
	/// Called when an item is deleted from the ``EventData`` list.
	///
	/// Will delete an instance of ``EventData`` from the ``modelContext`` given by the index.
	/// - Parameter offsets: An ``IndexSet`` used to delete the correct element from the  ``EventData`` array.
	///
	/// > Note: Will automatically save the data if `GlobalState.autoSave` is on.
	private func deleteItems(offsets: IndexSet) {
		withAnimation {
			for index in offsets {
				// delete the comic
				persistenceController.context.delete(events[index])
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
struct EventsStatsView_Previews: PreviewProvider {
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
		
		return EventsStatsView()
			.environment(\.modelContext, context)
	}
}


//
//  SeriesStatsView.swift
//  Comic Tracker
//
//  Created by James Coldwell on 9/8/2024.
//

import Foundation
import SwiftUI
import SwiftData

/// This contains a list of all of the series I have with a bunch of statistics for each series
struct SeriesStatsView: View {
	
	/// Controls all persistent data this view uses.
	@StateObject private var persistenceController = PersistenceController.shared
	/// Controls all global variables this view uses.
	@StateObject private var globalState = GlobalState.shared
	
	/// Stores an array of ``ComicData`` which contains all of the individual comic books, which are stored in the ``PersistenceController``.
	///
	/// This is sorted in decending order on the `comicId` to correctly be shown in  order in the list.
	@Query private var comics: [ComicData]
	/// Stores an array of ``ComicSeries`` which contains all of the individual comic series, which are stored in the ``PersistenceController``.
	@Query(sort: \ComicSeries.seriesId, order: .reverse)  private var series: [ComicSeries]
	
	/// needed so i can sort the series how i like as the above series is read only and cant be changed myself to sort it
	@State private var sortedSeries: [ComicSeries] = []
	
	// only define the options i want for sorting serires not all
	let sortOptionsForSeries: [SortOption] = [.id, .pagesRead, .issuesRead]
	
	// how am i sorting my list of series
	@State private var selectedSortOption: SortOption = .pagesRead

	/// Used to toggle between this main view and the ``AddNewComicView``
	@State private var navigateToAddNewComicView: Bool = false
	
	/// Currently selected series, saved so i can send it to the add new comic view when needed.
	/// Also used to select comic to edit total issues
	@State private var selectedSeries: ComicSeries?
	
	
	/// Width of the `readId` element in the list
	///
	/// Used to get nice spacing and to allow the comic name to have the most space possible
	private let readIdWidth: CGFloat = 45
	
	// top section
	private let seriesIdLeadingPadding: CGFloat = -12
	
	// bottom section
	private let statMajorWidth: CGFloat = 75
	private let statMajorTopPadding: CGFloat = -15
	private let majorDividerBottomPadding: CGFloat = 10
	private let issuesStatsTopPadding: CGFloat = -5
	private let minorIssuesVerticalDividerPaddingTop: CGFloat = 8
	private let minorIssuesVerticalDividerPaddingBottom: CGFloat = 10
	
	/// show sheet to update the series total issues
	@State private var showSheet: Bool = false
	/// Save the number to update the total issues of a series with
	@State private var totalIssues: String = ""
	
	
	
	// main views body
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
						
						Text("Series Name")
							.frame(maxWidth: .infinity, alignment: .center)
							.font(.headline)
							.padding(.leading, -10 - readIdWidth) // to adjust for the pages text being moved in slightly more
							.padding(.trailing, -20)
					}
					.padding(.top, 10)
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
							ForEach(sortOptionsForSeries) { option in
								Text(option.rawValue).tag(option)
							}
						}
					} label: {
						Label("Sort by: \(selectedSortOption.rawValue)", systemImage: "arrow.up.arrow.down")
							.padding()
					}
					.onChange(of: selectedSortOption) {
						sortSeries()
					}
					.onAppear {
						sortSeries() // Initial sorting on view load
					}
					.frame(height: 30)
				}
								
				// VStack list for all the series
				// the series will take up to lines each
				// one for the series, and one for stats
				List {
					ForEach(sortedSeries) { series in
						// this row
						VStack {
							// top row name
							HStack {
								Text(String(series.seriesId))
									.frame(width: 25, alignment: .center)
									.padding(.leading, seriesIdLeadingPadding)
									.modifier(MainDisplayTextStyle(globalState: globalState))
								
								Divider()
									.padding(.top, 1)
								
								VStack {
									Text(getSeriesFormattedBrandName(series: series))
										// force it to take up all the space so the id gets forced to the left
										.frame(maxWidth: .infinity)
										// remove as much padding from either side to give it as much space as possible (it is centered so normally you wont tell anyway)
										.padding(.leading, -5)
										.padding(.trailing, -15)
										.modifier(MainDisplayTextStyle(globalState: globalState))
									
									// dont display the series name if it is the same as the brand name
									if (getSeriesFormattedBrandName(series: series) != getSeriesFormattedName(series: series)) {
										Text(getSeriesFormattedName(series: series))
										// force it to take up all the space so the id gets forced to the left
											.frame(maxWidth: .infinity)
										// remove as much padding from either side to give it as much space as possible (it is centered so normally you wont tell anyway)
											.padding(.leading, -5)
											.padding(.trailing, -15)
											.modifier(MainDisplayTextStyle(globalState: globalState))
									}
								}
							}
							.frame(height: 35)
							.padding(.bottom, -3)
							
							Divider()
								.padding([.leading, .trailing], -10) // extend the sides of the divider
							
							// bottom row stats
							HStack {
								VStack {
									Text("Year")
										.modifier(MainDisplayTextStyle(globalState: globalState))
									
									Text(String(series.yearFirstPublished))
										.frame(width: statMajorWidth)
										.modifier(MainDisplayTextStyle(globalState: globalState))
								}
								.padding(.top, statMajorTopPadding)
								
								Divider()
									.padding(.bottom, majorDividerBottomPadding)
								
								VStack {
									Text("Issues")
										.padding([.top, .bottom], -6)
										.modifier(MainDisplayTextStyle(globalState: globalState))
									
									Divider()
									
									HStack {
										VStack {
											Text("Total")
												.modifier(MainDisplayTextStyle(globalState: globalState))
											Text(String(series.totalIssues))
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
											Text(String(series.issuesRead))
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
											Text(getIssuesLeft(series: series))
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
									Text(String(series.pagesRead))
										.frame(width: statMajorWidth)
										.modifier(MainDisplayTextStyle(globalState: globalState))
								}
								.padding(.top, statMajorTopPadding)
							}
							.frame(maxWidth: .infinity, alignment: .center)
							.padding([.leading, .trailing], -15)
							.padding(.bottom, -8)
						}
						.listRowBackground(globalState.getBrandColor(brandName: series.brandName))
						.swipeActions(edge: .leading) {
							Button(action: {
								selectedSeries = series
								navigateToAddNewComicView = true
							}) {
								Label("Add Comic From Series", systemImage: "plus")
							}
							.tint(.green)
						}
						.onTapGesture {
							selectedSeries = series
							totalIssues = ""
							showSheet = true
						}
					}
				}
				// this shrinks the gap at the top of the list so it sits under the headers nicely
				.onAppear(perform: {
					UICollectionView.appearance().contentInset.top = -35
				})
				// less padding either side of the list
				.padding(.leading, -10)
				.padding(.trailing, -10)
				.listRowSpacing(8)
			}
			.alert("Enter Total Issues", isPresented: $showSheet) {
				TextField("Total Issues", text: $totalIssues)
				Button("Save", action: {
					if let series = selectedSeries {
						if let newTotalIssues = UInt16(totalIssues) {
							series.totalIssues = newTotalIssues
						}
					}
					// no matter what happens after clicking save it will exit the alert
					showSheet = false
				})
				Button("Cancel", action: {
					showSheet = false
				})
			} message: {
				Text("How many issues are there in: \n\(selectedSeries?.seriesName ?? "UNKNOWN_SERIES") (\(String(selectedSeries?.yearFirstPublished ?? 0)))?")
			}
			.navigationTitle("Comic Series")
			.navigationDestination(isPresented: $navigateToAddNewComicView) {
				
				// try to go to comic data with data from the series
				if let series = selectedSeries {
					AddNewComicView(series: series)
					
				// if it fails just dont auto fill
				} else {
					AddNewComicView()
				}
			}
		}
	}
	
	
	/// Sorts the series based on its enum chosen
	private func sortSeries() {
		switch selectedSortOption {
			case .id:
				sortedSeries = series.sorted { $0.seriesId > $1.seriesId };
				
			case .pagesRead:
				sortedSeries = series.sorted { $0.pagesRead > $1.pagesRead };
				
			case .issuesRead:
				sortedSeries = series.sorted { $0.issuesRead > $1.issuesRead };
		}
	}
	
	/// Get the formatted series brand name
	private func getSeriesFormattedBrandName(series: ComicSeries) -> String {
		// full name unless its over the size limit
		if series.brandName.count > globalState.maxDisplayedSeriesViewStringLength {
			if !series.shortBrandName.isEmpty {
				return series.shortBrandName;
			}
		}
		
		return series.brandName;
	}
	
	/// Takes a series and returns a nicely formatted string to represent it.
	/// - Parameter series: ``ComicSeries`` which contains all the information about the series.
	/// - Returns: Formatted `String` representing the series.
	private func getSeriesFormattedName(series: ComicSeries) -> String {
		// This contains the shortest string found so far, so if nothing is short enough itll use the shortest string
		var shortestString: String = ""
		
		// otherwise try different combos to see what fits
		// Full name
		let fullString = series.seriesName;
		if fullString.count < globalState.maxDisplayedSeriesViewStringLength {
			return fullString;
		}
		// this is the initial shortest
		shortestString = fullString;
		
		
		// Short name
		if !series.shortSeriesName.isEmpty {
			let shortString = series.shortSeriesName;
			if shortString.count < globalState.maxDisplayedSeriesViewStringLength {
				return shortString;
			}
			
			// didnt fit but check if this is the smallest so far
			if shortString.count < shortestString.count {
				shortestString = shortString;
			}
		}
		
		// else if nothing else works just use shortestString i found
		return shortestString;
	}
	
	
	/// Get the number of issues left to read in this series.
	///
	/// This is done as a function because the values are UInt and i am subtracting it the app can crash if i underflow without catching that.
	///
	/// - Parameter series: A ``ComicSeries`` containing all the information about the series.
	/// - Returns: `String` which is the number of issues left to read, or 0 if failed.
	private func getIssuesLeft(series: ComicSeries) -> String {
		let read: UInt16 = series.issuesRead
		let total: UInt16 = series.totalIssues
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
}

/// Main view preview settings
struct SeriesStatsView_Previews: PreviewProvider {
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
		
		
		createTestComics(context: context)
		
		// lastly save it
		try? context.save()
		
		// set the context so my created preview one
		// so itll create the persistence controller like normal but then to context wont be whatever i have on disk itll be what i create here
		// this way creating and deleting comics will work correctly
		persistenceController.context = context
		
		return SeriesStatsView()
			.environment(\.modelContext, context)
	}
}

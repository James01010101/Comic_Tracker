//
//  CondensedComicView.swift
//  Comic Tracker
//
//  Created by James Coldwell on 8/10/2024.
//
// Needed to seperate out the main view into smaller views


import SwiftUI


struct CondensedComicView : View {
	// binding variable that come from the main view
	@Binding var brandName: String
	@Binding var shortBrandName: String
	@Binding var prioritizeShortBrandName: Bool
	
	@Binding var seriesName: String
	@Binding var shortSeriesName: String
	@Binding var prioritizeShortSeriesName: Bool
	
	@Binding var comicName: String
	@Binding var shortComicName: String
	@Binding var prioritizeShortComicName: Bool
	
	@Binding var yearFirstPublished: Int
	@Binding var issueNumber: String
	@Binding var totalPages: String
	
	
	/// Controls all global variables this view uses.
	@StateObject private var globalState = GlobalState.shared
	
	var body: some View {
		// if i am hiding them then instead i want to show the comics bubble
		HStack {
			Text(String(yearFirstPublished))
				.frame(width: 45, alignment: .center)
				.padding(.leading, -10)
				.modifier(MainDisplayTextStyle(globalState: globalState))
			
			
			Divider()
			
			VStack {
				// brand text
				let brandText = getDisplayBrandName();
				Text(brandText)
					.frame(maxWidth: .infinity, alignment: .center)
					.modifier(MainDisplayTextStyle(globalState: globalState))
				
				
				// series year and issue text
				let seriesText = getDisplaySeriesName();
				Text(seriesText)
					.frame(maxWidth: .infinity, alignment: .center)
					.modifier(MainDisplayTextStyle(globalState: globalState))
				
				
				// comic name / book text
				let comicNameText = getDisplayComicName();
				if !comicNameText.isEmpty {
					Text(comicNameText)
						.frame(maxWidth: .infinity, alignment: .center)
						.modifier(MainDisplayTextStyle(globalState: globalState))
				}
			}
			
			Divider()
			
			Text(totalPages)
				.frame(width: 35, alignment: .center)
				.padding(.trailing, -10)
				.modifier(MainDisplayTextStyle(globalState: globalState))
		}
		.listRowBackground(globalState.getBrandColor(brandName: brandName))
	}
	
	
	// get the string to display the brand/series/comic name for the condenced view
	private func getDisplayBrandName() -> String {
		let brandText = prioritizeShortBrandName ? shortBrandName : brandName;
		return brandText;
	}
	private func getDisplaySeriesName() -> String {
		// series year and issue text
		let seriesText = (prioritizeShortSeriesName ? shortSeriesName : seriesName) + " #" + String(issueNumber);
		return seriesText;
	}
	private func getDisplayComicName() -> String {
		let comicText = (prioritizeShortComicName ? shortComicName : comicName);
		return comicText;
	}
}

//
//  SeriesView.swift
//  Comic Tracker
//
//  Created by James Coldwell on 8/10/2024.
//
// holds the Series

import SwiftUI

extension AddNewComicView {
	struct SeriesInputsView: View {
		/// Controls all global variables this view uses.
		@StateObject private var globalState = GlobalState.shared
		
		// consts for styling
		let iconWidth: CGFloat
		let leadingPadding: CGFloat
		let trailingTextPadding: CGFloat
		
		// binding vars
		@Binding var seriesName: String
		@Binding var shortSeriesName: String
		@Binding var prioritizeShortSeriesName: Bool
		
		/// Lock the series toggle so it cant be changed
		@State private var lockSeriesToggle: Bool = false
		
		var body: some View {
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
		}
	}
}

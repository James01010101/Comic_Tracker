//
//  BookView.swift
//  Comic Tracker
//
//  Created by James Coldwell on 8/10/2024.
//
// holds the Book

import SwiftUI

extension AddNewComicView {
	struct BookInputsView: View {
		/// Controls all global variables this view uses.
		@StateObject private var globalState = GlobalState.shared
		
		// consts for styling
		let iconWidth: CGFloat
		let leadingPadding: CGFloat
		let trailingTextPadding: CGFloat
		
		// binding vars
		@Binding var comicName: String
		@Binding var shortComicName: String
		@Binding var prioritizeShortComicName: Bool
		
		/// Lock the comic toggle so it cant be changed
		@State private var lockComicToggle: Bool = false
		
		var body: some View {
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
		}
	}
}

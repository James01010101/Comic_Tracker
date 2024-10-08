//
//  BrandView.swift
//  Comic Tracker
//
//  Created by James Coldwell on 8/10/2024.
//
// holds the Brand

import SwiftUI

extension AddNewComicView {
	struct BrandInputsView: View {
		/// Controls all global variables this view uses.
		@StateObject private var globalState = GlobalState.shared
		
		// consts for styling
		let iconWidth: CGFloat
		let leadingPadding: CGFloat
		let trailingTextPadding: CGFloat
		
		// binding vars
		@Binding var brandName: String
		@Binding var shortBrandName: String
		@Binding var prioritizeShortBrandName: Bool
		
		/// Lock the brand toggle so it cant be changed
		@State private var lockBrandToggle: Bool = false
		
		var body: some View {
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
		}
	}
}

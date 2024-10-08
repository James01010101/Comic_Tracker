//
//  Date.swift
//  Comic Tracker
//
//  Created by James Coldwell on 8/10/2024.
//
// date input view

import SwiftUI

extension AddNewComicView {
	struct DateInputView: View {
		// consts for styling
		let iconWidth: CGFloat
		let leadingPadding: CGFloat
		let trailingTextPadding: CGFloat
		
		@Binding var comicRead: ComicReadEnum
		@Binding var dateKnown: Bool
		@Binding var dateRead: Date
		
		
		public var body: some View {
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
						DatePicker("Date Read", selection: $dateRead, displayedComponents: .date)
							.datePickerStyle(GraphicalDatePickerStyle())
							.frame(minHeight: 375) // so when it is shown it fits the container and doesnt push other elements out of position
					}
				}
			}
		}
	}
}

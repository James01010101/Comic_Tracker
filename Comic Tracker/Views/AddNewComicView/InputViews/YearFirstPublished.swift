//
//  YearFirstPublished.swift
//  Comic Tracker
//
//  Created by James Coldwell on 8/10/2024.
//
// holds the Year

import SwiftUI

extension AddNewComicView {
	struct YearInputView: View {
		// consts for styling
		let iconWidth: CGFloat
		let leadingPadding: CGFloat
		let trailingTextPadding: CGFloat
		
		// binding vars
		@Binding var yearFirstPublished: Int
		
		var body: some View {
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
	}
}

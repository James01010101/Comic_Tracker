//
//  Purpose.swift
//  Comic Tracker
//
//  Created by James Coldwell on 8/10/2024.
//
// holds the Purpose

import SwiftUI

extension AddNewComicView {
	struct PurposeInputView: View {
		// consts for styling
		let iconWidth: CGFloat
		let leadingPadding: CGFloat
		let trailingTextPadding: CGFloat
		
		// binding vars
		@Binding var purpose: String
		
		var body: some View {
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
		}
	}
}

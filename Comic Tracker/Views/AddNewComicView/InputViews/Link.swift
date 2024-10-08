//
//  LinkInputView.swift
//  Comic Tracker
//
//  Created by James Coldwell on 8/10/2024.
//
// link view

import SwiftUI

extension AddNewComicView {
	struct LinkInputView: View {
		// consts for styling
		let iconWidth: CGFloat
		let leadingPadding: CGFloat
		let trailingTextPadding: CGFloat
		
		@Binding var marvelUltimateLink: String
		
		public var body: some View {
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
		}
	}
}

//
//  Event.swift
//  Comic Tracker
//
//  Created by James Coldwell on 8/10/2024.
//
// holds the Event

import SwiftUI

extension AddNewComicView {
	struct EventInputView: View {
		// consts for styling
		let iconWidth: CGFloat
		let leadingPadding: CGFloat
		let trailingTextPadding: CGFloat
		
		// binding vars
		@Binding var eventName: String
		
		var body: some View {
			HStack {
				Image(systemName: "tag")
					.frame(width: iconWidth, alignment: .center)
				
				Text("Event?")
					.font(.headline)
				
				TextEditor(text: $eventName)
					.multilineTextAlignment(.trailing)
					.padding(.bottom, -5)
					.padding(.trailing, trailingTextPadding)
			}
			.padding(.leading, leadingPadding)
		}
	}
}

//
//  PagesInputView.swift
//  Comic Tracker
//
//  Created by James Coldwell on 8/10/2024.
//
// input view for pages

import SwiftUI

extension AddNewComicView {
	struct PagesInputView: View {
		// consts for styling
		let iconWidth: CGFloat
		let leadingPadding: CGFloat
		let trailingTextPadding: CGFloat
		
		@Binding var totalPages: String
		
		// editing booleans so that i can align text center if editing otherwise right
		@State private var editingPages: Bool = false
		
		
		public var body: some View {
			HStack {
				Image(systemName: "doc.plaintext")
					.frame(width: iconWidth, alignment: .center)
				
				Text("Pages")
					.font(.headline)
				
				TextField("", text: $totalPages, onEditingChanged: { editing in
					self.editingPages = editing;
				})
				.keyboardType(.numberPad)
				.multilineTextAlignment(self.editingPages ? .center : .center) // can have trailing if its not editing
				.padding(.trailing, trailingTextPadding)
				
				// Minus Button
				Button(action: {
					if let currentPages = Int(totalPages) {
						if currentPages > 0 {
							// required otherwise it wont update on the frontend correctly
							DispatchQueue.main.async { totalPages = String(currentPages - 1) }
						}
					}
				}) {
					Image(systemName: "minus.circle")
						.foregroundColor(.red)
				}
				// required to override the button touch while being in a list, without this the list will always click both buttons at the same time
				.buttonStyle(PlainButtonStyle())
				
				
				// Plus Button
				Button(action: {
					if let currentPages = Int(totalPages) {
						DispatchQueue.main.async { totalPages = String(currentPages + 1) }
					}
				}) {
					Image(systemName: "plus.circle")
						.foregroundColor(.green)
				}
				.buttonStyle(PlainButtonStyle()) // Disable default List button behavior
			}
			.padding(.leading, leadingPadding)
		}
	}
}

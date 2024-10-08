//
//  IssueInputView.swift
//  Comic Tracker
//
//  Created by James Coldwell on 8/10/2024.
//
// holds the issue number input

import SwiftUI

extension AddNewComicView {
	struct IssueInputView: View {
		// consts for styling
		let iconWidth: CGFloat
		let leadingPadding: CGFloat
		let trailingTextPadding: CGFloat
		
		// binding vars
		@Binding var issueNumber: String
		
		// this views own vars
		// editing booleans so that i can align text center if editing otherwise right
		@State private var editingIssues: Bool = false
		
		
		var body: some View {
			HStack {
				Image(systemName: "number.circle")
					.frame(width: iconWidth, alignment: .center)
				
				Text("Issue")
					.font(.headline)
				
				TextField("", text: $issueNumber, onEditingChanged: { editing in
					self.editingIssues = editing;
				})
				.keyboardType(.numberPad)
				.multilineTextAlignment(self.editingIssues ? .center : .center) // can have trailing if its not editing
				.padding(.trailing, trailingTextPadding)
				
				// Minus Button
				Button(action: {
					if let currentIssueNum = Int(issueNumber) {
						if currentIssueNum > 0 {
							DispatchQueue.main.async { issueNumber = String(currentIssueNum - 1) }
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
					if let currentIssueNum = Int(issueNumber) {
						DispatchQueue.main.async { issueNumber = String(currentIssueNum + 1) }
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

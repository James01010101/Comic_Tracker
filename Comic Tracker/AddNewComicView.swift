//
//  AddNewComicView.swift
//  Comic Tracker
//
//  Created by James Coldwell on 29/7/2024.
//

import Foundation
import SwiftUI
import SwiftData

struct AddNewComicView: View {
	@Environment(\.modelContext) private var modelContext: ModelContext
	@Environment(\.presentationMode) var presentationMode
	
	// query variables
	@Query private var generalComicStats: [GeneralComicStats]
	
	
	@State private var readId: String = ""
	@State private var comicFullTitle: String = ""
	@State private var yearFirstPublished: Int = 0
	@State private var issueNumber: String = ""
	@State private var totalPages: String = ""
	@State private var eventName: String = ""
	@State private var purpose: String = ""
	
	var body: some View {
		Form {
			Section(header: Text("Read ID")) {
				HStack {
					Image(systemName: "barcode")
					TextField("Read ID", text: $readId)
						.onAppear {
							if let stats = generalComicStats.first {
								self.readId = String(stats.getReadId())
							} else {
								// Handle the case where generalComicStats is empty
								print("GeneralComicStats is empty")
							}
						}
						.keyboardType(.phonePad)
				}
			}
			
			Section(header: Text("Full Book Title")) {
				HStack {
					Image(systemName: "book")
					TextField("Title", text: $comicFullTitle)
				}
			}
			
			Section(header: Text("Year First Published")) {
				HStack {
					Image(systemName: "calendar")
					Picker("Year First Published", selection: $yearFirstPublished) {
						ForEach(1800...2100, id: \.self) { year in
							Text(formattedNumber(year)).tag(year)
						}
					}
					.pickerStyle(WheelPickerStyle())
					.onAppear {
						self.yearFirstPublished = Calendar.current.component(.year, from: Date())
					}
				}
			}
			
			Section(header: Text("Issue Number")) {
				HStack {
					Image(systemName: "number.circle")
					TextField("Issue Number", text: $issueNumber)
						.keyboardType(.numberPad)
				}
			}
			
			Section(header: Text("Total Pages")) {
				HStack {
					Image(systemName: "doc.plaintext")
					TextField("Total Pages", text: $totalPages)
						.keyboardType(.numberPad)
				}
			}
			
			Section(header: Text("Event Name")) {
				HStack {
					Image(systemName: "tag")
					TextField("Event Name", text: $eventName)
				}
			}
			
			Section(header: Text("Purpose")) {
				HStack {
					Image(systemName: "pencil")
					TextField("Purpose", text: $purpose)
				}
			}
			
			Section {
				Button(action: saveComic) {
					HStack {
						Spacer()
						Text("Save")
							.bold()
						Spacer()
					}
				}
			}
			.navigationTitle("Add New Comic View")
		}
		.scrollDismissesKeyboard(.interactively)
	}
	
	// format the numbers without commas
	private func formattedNumber(_ number: Int) -> String {
		let numberFormatter = NumberFormatter()
		numberFormatter.usesGroupingSeparator = false
		return numberFormatter.string(from: NSNumber(value: number)) ?? "\(number)"
	}
	
	// save the newly created comic to the modelContext
	private func saveComic() {
		let newComic = ComicData(
			readId: UInt32(readId) ?? 0,
			comicFullTitle: comicFullTitle,
			yearFirstPublished: UInt16(self.yearFirstPublished),
			issueNumber: UInt16(issueNumber) ?? 0,
			totalPages: UInt16(totalPages) ?? 0,
			eventName: eventName,
			purpose: purpose
		)
		
		modelContext.insert(newComic)
		try? modelContext.save()
		
		
		// increment the readID (only do this once a comic has been submitted, otherwise i can cancel it and it shouldnt increase
		if let stats = generalComicStats.first {
			stats.incrementReadId()
		}
		
		// Dismiss the view back to the main view
		presentationMode.wrappedValue.dismiss()
	}
	
}

struct AddComicView_Previews: PreviewProvider {
	static var previews: some View {
		AddNewComicView()
			.modelContainer(for: [ComicData.self, GeneralComicStats.self], inMemory: true)
	}
}


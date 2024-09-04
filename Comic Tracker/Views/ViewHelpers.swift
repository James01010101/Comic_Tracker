//
//  ViewHelpers.swift
//  Comic Tracker
//
//  Created by James Coldwell on 4/9/2024.
//
// This file will contain lots of helpful functions for the view which are global across the project

import Foundation
import SwiftUI


struct MainDisplayTextStyle: ViewModifier {
	@ObservedObject var globalState: GlobalState

	func body(content: Content) -> some View {
		content
			.bold()
			.font(.system(size: globalState.mainDisplayTextSize))
			.foregroundColor(globalState.mainDisplayTextColour)
	}
}

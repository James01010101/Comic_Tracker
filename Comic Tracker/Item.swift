//
//  Item.swift
//  Comic Tracker
//
//  Created by James Coldwell on 28/7/2024.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}

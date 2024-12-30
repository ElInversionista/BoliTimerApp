//
//  Item.swift
//  BoliTimer
//
//  Created by Luis Alejandro Bolivar Aramayo on 30/12/24.
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

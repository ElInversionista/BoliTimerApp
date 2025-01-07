//
//  BoliTimerApp.swift
//  BoliTimer
//
//  Created by Luis Alejandro Bolivar Aramayo on 30/12/24.
//

import SwiftUI
import SwiftData

@main
struct BoliTimerApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .defaultSize(width: 1900, height: 800) // Initial window size
        .windowResizability(.contentSize) // Allows resizing based on content
    }
}

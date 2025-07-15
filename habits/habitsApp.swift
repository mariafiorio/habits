//
//  habitsApp.swift
//  habits
//
//  Created by Maria on 11/07/25.
//

import SwiftUI

@main
struct habitsApp: App {
    @StateObject private var notificationManager = NotificationManager.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

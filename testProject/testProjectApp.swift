//
//  authdemoApp.swift
//  authdemo
//
//  Created by orino on 26/8/2025.
//

import SwiftUI
import CoreData
import Firebase

@main
struct testProjectApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    let persistenceController = PersistenceController.shared

    @StateObject private var authViewModel = AuthViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(authViewModel)
        }
    }
}

//
//  ContentView.swift
//  testprotect
//
//  Created by orino on 31/10/2025.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        TabView {
            Tab.init("Voice", systemImage: "sparkles.2") {
                MicView()
            }
            Tab.init("Auth", systemImage: "person.fill") {
                AuthScreenView()
            }
        }
        .onAppear {
            Task {
                if let token = await authViewModel.getIdToken() {
                    await sendRequestWithBearer(bearer: token)
                }
            }
        }
        .onChange(of: authViewModel.isLoggedIn) { _, newValue in
            if newValue {
                Task {
                    if let token = await authViewModel.getIdToken() {
                        await sendRequestWithBearer(bearer: token)
                    }
                }
            }
        }

    }
}

#Preview {
//    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}

//
//  DemoXCTestApp.swift
//  DemoXCTest
//
//  Created by Mootaz Bahri on 07.12.24.
//

import SwiftUI

@main
struct DemoXCTestApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}

//
//  mtxluaApp.swift
//  Shared
//
//  Created by cn on 2020/12/4.
//

import SwiftUI

@main
struct mtxluaApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}

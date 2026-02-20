//
//  MoveDailyApp.swift
//  MoveDaily
//
//  Created by Rachit Sharma on 17/02/2026.
//

import SwiftUI

@main
struct MoveDailyApp: App {
    @State var homeViewModel = HomeViewModel(healthManager: HealthManager())
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(homeViewModel)
        }
    }
}


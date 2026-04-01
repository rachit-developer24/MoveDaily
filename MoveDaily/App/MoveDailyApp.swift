//
//  MoveDailyApp.swift
//  MoveDaily
//
//  Created by Rachit Sharma on 17/02/2026.
//

import SwiftUI

@main
struct MoveDailyApp: App {
    private let healthManager = HealthManager()
    private let mockHealthManager = MockHealthManager()
    @State var homeViewModel: HomeViewModel
    @State var workoutViewModel: WorkoutViewModel
    init(){
        self.homeViewModel = HomeViewModel(healthManager:healthManager)
        self.workoutViewModel = WorkoutViewModel(service: healthManager)
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(homeViewModel)
                .environment(workoutViewModel)
        }
    }
}


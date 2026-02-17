//
//  HomeViewModel.swift
//  MoveDaily
//
//  Created by Rachit Sharma on 17/02/2026.
//

import Foundation
import Observation
import SwiftUI
@Observable
class HomeViewModel{
    var healthData:[ActivityCard] = []

    func fetchHealthData()async{
        do{
            self.healthData = [
                ActivityCard(
                    id: "steps",
                    steps: 5_432,
                    title: "Steps",
                    goal: 10_000,
                    image: "figure.walk",
                    color: .blue
                ),
                ActivityCard(
                    id: "running",
                    steps: 7_850,
                    title: "Run",
                    goal: 8_000,
                    image: "figure.run",
                    color: .red
                ),
                ActivityCard(
                    id: "cycling",
                    steps: 3_200,
                    title: "Cycle",
                    goal: 6_000,
                    image: "bicycle",
                    color: .green
                ),
                ActivityCard(
                    id: "hiking",
                    steps: 9_120,
                    title: "Hike",
                    goal: 12_000,
                    image: "figure.hiking",
                    color: .orange
                )
            ]
        }catch{
            print("print error \(error.localizedDescription)")
        }
    }
}

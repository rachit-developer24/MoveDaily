//
//  WorkoutViewModel.swift
//  MoveDaily
//
//  Created by Rachit Sharma on 17/02/2026.
//

import Foundation
@Observable
class WorkoutViewModel{
   var workouts: [WorkoutModel] = []
    
    
    func fetchWorkouts()async{
        self.workouts = [
            WorkoutModel(
                id: "w1",
                title: "Morning Run",
                image: "figure.run",
                duration: "32 min",
                date: "26 Jan",
                calories: "320 kcal"
            ),
            WorkoutModel(
                id: "w2",
                title: "Evening Walk",
                image: "figure.walk",
                duration: "45 min",
                date: "25 Jan",
                calories: "210 kcal"
            ),
            WorkoutModel(
                id: "w3",
                title: "Cycling",
                image: "bicycle",
                duration: "28 min",
                date: "24 Jan",
                calories: "280 kcal"
            ),
            WorkoutModel(
                id: "w4",
                title: "Hiking",
                image: "figure.hiking",
                duration: "60 min",
                date: "23 Jan",
                calories: "450 kcal"
            ),
            WorkoutModel(
                id: "w5",
                title: "Quick Run",
                image: "figure.run",
                duration: "20 min",
                date: "22 Jan",
                calories: "190 kcal"
            ),
            WorkoutModel(
                id: "w6",
                title: "Night Walk",
                image: "figure.walk",
                duration: "38 min",
                date: "21 Jan",
                calories: "230 kcal"
            )
        ]
    }
}

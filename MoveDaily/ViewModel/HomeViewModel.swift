//
//  HomeViewModel.swift
//  MoveDaily
//
//  Created by Rachit Sharma on 17/02/2026.
//

import Foundation
import Observation
import SwiftUI
import HealthKit
@MainActor
@Observable
class HomeViewModel{
    var calories:Int = 0
    var active:Int = 0
    var stand:Int = 0
    var error:Error?
    let healthManager:HealthManager
    init(healthManager:HealthManager){
        self.healthManager = healthManager
     
    }
    var weeklyWorkoutData: [ActivityCard] = []
    var healthData:[ActivityCard] = []
    
   
    

    
    func requestToAccess()async{
        do{
            guard HKHealthStore.isHealthDataAvailable()else{
                print("no data")
                return
            }
            try await healthManager.requestHealthkitAccess()
            print("healthManager called")
        }catch{
            print("Debug: error\(error.localizedDescription)")
            self.error = error
        }
    }
    
    
    func funcDashboard()async{
        do{
            async let calories = healthManager.fetchCaloriesBurned()
            async let active =  healthManager.fetchExerciseTime()
            async let stand = healthManager.fetchTodayStandHours()
            async let steps = healthManager.fetchStepCount()
            
            let(calsDouble,activeInt,standInt,stepsInt) = try await (calories,active,stand,steps)
            self.calories = Int(calsDouble.rounded())
            self.active = activeInt
            self.stand = standInt
            
            self.healthData = [
                ActivityCard(
                    id: "steps",
                    amount: stepsInt,
                    title: "Steps",
                    goal: 10_000,
                    image: "figure.walk",
                    color: .blue
                ),
                ActivityCard(
                    id: "calories",
                    amount: Int(calsDouble.rounded()),
                    title: "Calories",
                    goal: 300,
                    image: "flame.fill",
                    color: .red
                ),
                ActivityCard(
                    id: "cycling",
                    amount: 3_200,
                    title: "Cycle",
                    goal: 6_000,
                    image: "bicycle",
                    color: .green
                ),
                ActivityCard(
                    id: "hiking",
                    amount: 9_120,
                    title: "Hike",
                    goal: 12_000,
                    image: "figure.hiking",
                    color: .orange
                )
            ]
            
        }catch{
            self.error = error
            print(error.localizedDescription)
        }
    }

    
    func fetchWeeklyWorkoutCards() async {
        do {
            let minsByType = try await healthManager.fetchWeeklyWorkoutMinutesByType()
    

            func mins(_ type: HKWorkoutActivityType) -> Int {
                minsByType[type, default: 0]
               
            }

            self.weeklyWorkoutData = [
                ActivityCard(
                    id: "wk_running",
                    amount: mins(.running),
                    title: "Running",
                    goal: 150, 
                    image: "figure.run",
                    color: .green
                ),
                ActivityCard(
                    id: "wk_strength",
                    amount: mins(.traditionalStrengthTraining),
                    title: "Strength",
                    goal: 120,
                    image: "dumbbell",
                    color: .blue
                ),
                ActivityCard(
                    id: "wk_cycling",
                    amount: mins(.cycling),
                    title: "Cycling",
                    goal: 120,
                    image: "bicycle",
                    color: .green
                ),
                ActivityCard(
                    id: "wk_soccer",
                    amount: mins(.soccer),
                    title: "Soccer",
                    goal: 90,
                    image: "figure.soccer",
                    color: .indigo
                )
            ]
           

        } catch {
            self.error = error
            self.weeklyWorkoutData = []
        }
    }
  
}

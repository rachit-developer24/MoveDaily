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
            
            let(calsDouble,activeInt,standInt) = try await (calories,active,stand)
            self.calories = Int(calsDouble.rounded())
            self.active = activeInt
            self.stand = standInt
           
            
        }catch{
            self.error = error
        }
    }

    

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
            self.error = error
        }
    }
}

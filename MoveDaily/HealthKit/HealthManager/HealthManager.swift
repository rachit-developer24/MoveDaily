//
//  HealthKitManager.swift
//  MoveDaily
//
//  Created by Rachit Sharma on 18/02/2026.
//

import Foundation
import HealthKit

class HealthManager{
  let healthStore = HKHealthStore()
         func requestHealthkitAccess()async throws{
             let calories = HKQuantityType(.activeEnergyBurned)
             let exercise = HKQuantityType(.appleExerciseTime)
             let stand = HKCategoryType(.appleStandHour)
             let healthTypes: Set<HKObjectType> = [calories,exercise,stand]
             try await healthStore.requestAuthorization(toShare: [], read: healthTypes)
         }
         
         func fetchCaloriesBurned()async throws ->Double{
             let calories = HKQuantityType(.activeEnergyBurned)
             let startDate = Calendar.current.startOfDay(for: Date())
             let predicate = HKQuery.predicateForSamples(withStart: startDate, end: Date())
            return try await withCheckedThrowingContinuation { continuation  in
                let query = HKStatisticsQuery(quantityType: calories, quantitySamplePredicate: predicate, options: .cumulativeSum) {_ ,results, error in
                    if let error = error {
                    continuation.resume(throwing: error)
                    return
                    }
                    let quantity = results?.sumQuantity()
                    let caloriesBurned = quantity?.doubleValue(for: .kilocalorie()) ?? 0
                    continuation.resume(returning: caloriesBurned)
                }
                self.healthStore.execute(query)
             }
         }
         
         func fetchExerciseTime()async throws ->Int{
             let exerciseTime = HKQuantityType(.appleExerciseTime)
             let startDate = Calendar.current.startOfDay(for: Date())
             let predicate = HKQuery.predicateForSamples(withStart: startDate, end: Date())
             
             return try await withCheckedThrowingContinuation { continuation in
                 let query = HKStatisticsQuery(quantityType: exerciseTime, quantitySamplePredicate: predicate, options:.cumulativeSum) { _, results, error in
                     if let error = error {
                         continuation.resume(throwing: error)
                         return
                     }
                     let minutes = results?.sumQuantity()?.doubleValue(for: .minute())
                     continuation.resume(returning: Int(minutes?.rounded() ?? 0))
                     
                 }
                 self.healthStore.execute(query)
             }
            
         }

         func fetchTodayStandHours() async throws -> Int {
             guard let standType = HKObjectType.categoryType(forIdentifier: .appleStandHour) else {
                 throw NSError(domain: "HealthKit", code: 0, userInfo: [NSLocalizedDescriptionKey: "StandHour not available"])
             }
             let startDate = Calendar.current.startOfDay(for: Date())
             let predicate = HKQuery.predicateForSamples(withStart: startDate, end: Date())

             return try await withCheckedThrowingContinuation { continuation in
                 let query = HKSampleQuery(
                     sampleType: standType,
                     predicate: predicate,
                     limit: HKObjectQueryNoLimit,
                     sortDescriptors: nil
                 ) { _, samples, error in

                     if let error = error {
                         continuation.resume(throwing: error)
                         return
                     }

                     let standSamples = (samples as? [HKCategorySample]) ?? []

                     let stoodHours = standSamples.filter {
                         $0.value == HKCategoryValueAppleStandHour.stood.rawValue
                     }.count

                     continuation.resume(returning: stoodHours)
                 }

                 self.healthStore.execute(query)

             }
         }

    
}


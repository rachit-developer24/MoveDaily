//
//  HealthKitManager.swift
//  MoveDaily
//
//  Created by Rachit Sharma on 18/02/2026.
//
import SwiftUI
import Foundation
import HealthKit

class HealthManager{
  let healthStore = HKHealthStore()
         func requestHealthkitAccess()async throws{
             let calories = HKQuantityType(.activeEnergyBurned)
             let exercise = HKQuantityType(.appleExerciseTime)
             let stand = HKCategoryType(.appleStandHour)
             let steps = HKQuantityType(.stepCount)
             let workout = HKObjectType.workoutType()
             let healthTypes: Set<HKObjectType> = [calories,exercise,stand,steps,workout]
             try await healthStore.requestAuthorization(toShare: [], read: healthTypes)
         }
         
         func fetchCaloriesBurned()async throws ->Double{
             let calories = HKQuantityType(.activeEnergyBurned)
             let startDate = Calendar.current.startOfDay(for: Date())
             let predicate = HKQuery.predicateForSamples(withStart: startDate, end: Date())
            return try await withCheckedThrowingContinuation { continuation  in
                let query = HKStatisticsQuery(quantityType: calories, quantitySamplePredicate: predicate, options: .cumulativeSum) {_ ,results, error in
                    if let nsError = error as NSError?,
                                nsError.domain == "com.apple.healthkit",
                                nsError.code == 11 {
                                 continuation.resume(returning: 0)  // ✅ no data -> 0 steps
                                 return
                             }
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
                     
                     if let nsError = error as NSError?,
                                 nsError.domain == "com.apple.healthkit",
                                 nsError.code == 11 {
                                  continuation.resume(returning: 0)  // ✅ no data -> 0 steps
                                  return
                              }

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
    
    func fetchStepCount() async throws -> Int {
        let steps = HKQuantityType(.stepCount)
        let startDate = Calendar.current.startOfDay(for: Date())
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: Date())
        return try await withCheckedThrowingContinuation { continuation in
            let query = HKStatisticsQuery(quantityType: steps, quantitySamplePredicate: predicate,options: .cumulativeSum) { _, results, error in
                if let nsError = error as NSError?,
                            nsError.domain == "com.apple.healthkit",
                            nsError.code == 11 {
                             continuation.resume(returning: 0)  // ✅ no data -> 0 steps
                             return
                         }
                if let error = error{
                    continuation.resume(throwing: error)
                    return
                }
                let totalSteps =  results?.sumQuantity()?.doubleValue(for: .count()) ?? 0
                continuation.resume(returning: Int(totalSteps))
                
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

                     if let nsError = error as NSError?,
                                 nsError.domain == "com.apple.healthkit",
                                 nsError.code == 11 {
                                  continuation.resume(returning: 0)  // ✅ no data -> 0 steps
                                  return
                              }
                     
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
    
    func fetchWorkoutsThisWeek()async throws ->[HKWorkout]{
        let workout = HKObjectType.workoutType()
        let startOfWeek = Calendar.current.dateInterval(of: .weekOfYear, for: Date())!.start
        let predicate = HKQuery.predicateForSamples(withStart: startOfWeek, end: Date())
        let sort = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
       return try await  withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(sampleType: workout, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: [sort]) { _, Result, error in
                if let nserror = error as NSError? {
                    if nserror.code == 11{
                        continuation.resume(returning: [])
                        return
                    }
                }
                if let error = error{
                    continuation.resume(throwing: error)
                    return
                }
                continuation.resume(returning: (Result as? [HKWorkout]) ?? [] )
            }
           self.healthStore.execute(query)
        }
    }

   
    func fetchWeeklyWorkoutMinutesByType() async throws -> [HKWorkoutActivityType: Int] {

        let workouts = try await fetchWorkoutsThisWeek()

        var minsByType: [HKWorkoutActivityType: Int] = [:]

        for workout in workouts {
            let type = workout.workoutActivityType

            let minutes = Int((workout.duration / 60.0).rounded())

            minsByType[type, default: 0] += minutes
          
        }

        return minsByType
        
    }
    
    func fetchRecentWorkouts(limit:Int = 10)async throws ->[WorkoutModel]{
        let workoutsType = HKObjectType.workoutType()
        let start = Calendar.current.date(byAdding: .day, value: -30, to: Date())
        let predicate = HKQuery.predicateForSamples(withStart: start, end: Date())
        let sort = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        let workouts:[HKWorkout] = try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(sampleType: workoutsType, predicate: predicate, limit: limit, sortDescriptors: [sort]) { _ , results, error in
                if let nsError = error as NSError?,
                            nsError.domain == "com.apple.healthkit",
                            nsError.code == 11 {
                             continuation.resume(returning: [])  // ✅ no data -> 0 steps
                             return
                         }
                if let error = error{
                    continuation.resume(throwing: error)
                    return
                }
                continuation.resume(returning: (results as? [HKWorkout]) ?? [])
            }
            self.healthStore.execute(query)
            }
        let df = DateFormatter()
               df.dateFormat = "d MMM"
      
        return workouts.map { w in
            let minutes = Int((w.duration / 60).rounded())

            let kcalDouble = w.totalEnergyBurned?.doubleValue(for: .kilocalorie()) ?? 0
            let kcal = Int(kcalDouble.rounded())

            // ✅ Tutor-style: type -> name/icon
            let title = w.workoutActivityType.name
            let image = w.workoutActivityType.image

            return WorkoutModel(
                id: w.uuid.uuidString,
                title: title,
                image: image,
                duration: "\(minutes) min",
                date: df.string(from: w.startDate),
                calories: "\(kcal) kcal"
            )
        }
        }
    }
   

extension HKWorkoutActivityType {
    
    var name: String {
        switch self {
        case .running: return "Running"
        case .walking: return "Walking"
        case .cycling: return "Cycling"
        case .kickboxing: return "Kickboxing"
        case .traditionalStrengthTraining: return "Strength"
        case .soccer: return "Soccer"
        case .hiking: return "Hiking"
        default: return "Workout"
        }
    }

    var image: String {
        switch self {
        case .running: return "figure.run"
        case .walking: return "figure.walk"
        case .cycling: return "bicycle"
        case .kickboxing: return "figure.boxing"
        case .traditionalStrengthTraining: return "dumbbell"
        case .soccer: return "figure.soccer"
        case .hiking: return "figure.hiking"
        default: return "figure.mixed.cardio"
        }
    }

    var tintColor: Color {
        switch self {
        case .running, .cycling, .hiking: return .blue
        case .walking: return .green
        case .kickboxing: return .red
        case .traditionalStrengthTraining: return .orange
        case .soccer: return .indigo
        default: return .purple
        }
    }
}




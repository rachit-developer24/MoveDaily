//
//  HealthKitManager.swift
//  MoveDaily
//
//  Created by Rachit Sharma on 18/02/2026.
//
import SwiftUI
import Foundation
import HealthKit


final class HealthManager:HealthManagerProtocol {

    let healthStore = HKHealthStore()

    // MARK: - Authorization
    func requestHealthkitAccess() async throws {
        let basalCalories = HKQuantityType(.basalEnergyBurned)
        let calories = HKQuantityType(.activeEnergyBurned)

        // These are Apple Rings metrics (often 0 without Apple Watch),
        // but we keep permission because your old code uses them.
        let exercise = HKQuantityType(.appleExerciseTime)
        let stand = HKObjectType.categoryType(forIdentifier: .appleStandHour)!

        let steps = HKQuantityType(.stepCount)
        let workout = HKObjectType.workoutType()

        // ✅ Sleep
        let sleep = HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!

        let healthTypes: Set<HKObjectType> = [
            basalCalories, calories,
            exercise, stand,
            steps, workout,
            sleep
        ]

        try await healthStore.requestAuthorization(toShare: [], read: healthTypes)
    }

    // MARK: - Calories
    func fetchBasalCaloriesBurned() async throws -> Double {
        let basal = HKQuantityType(.basalEnergyBurned)
        let startDate = Calendar.current.startOfDay(for: Date())
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: Date())

        return try await withCheckedThrowingContinuation { continuation in
            let query = HKStatisticsQuery(
                quantityType: basal,
                quantitySamplePredicate: predicate,
                options: .cumulativeSum
            ) { _, results, error in

                if let nsError = error as NSError?,
                   nsError.domain == "com.apple.healthkit",
                   nsError.code == 11 {
                    continuation.resume(returning: 0)
                    return
                }

                if let error {
                    continuation.resume(throwing: error)
                    return
                }

                let kcal = results?.sumQuantity()?.doubleValue(for: .kilocalorie()) ?? 0
                continuation.resume(returning: kcal)
            }

            self.healthStore.execute(query)
        }
    }

    func fetchCaloriesBurned() async throws -> Double {
        let calories = HKQuantityType(.activeEnergyBurned)
        let startDate = Calendar.current.startOfDay(for: Date())
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: Date())

        return try await withCheckedThrowingContinuation { continuation in
            let query = HKStatisticsQuery(
                quantityType: calories,
                quantitySamplePredicate: predicate,
                options: .cumulativeSum
            ) { _, results, error in

                if let nsError = error as NSError?,
                   nsError.domain == "com.apple.healthkit",
                   nsError.code == 11 {
                    continuation.resume(returning: 0)
                    return
                }

                if let error {
                    continuation.resume(throwing: error)
                    return
                }

                let caloriesBurned = results?.sumQuantity()?.doubleValue(for: .kilocalorie()) ?? 0
                continuation.resume(returning: caloriesBurned)
            }

            self.healthStore.execute(query)
        }
    }

    // MARK: - Steps
    func fetchStepCount() async throws -> Int {
        let steps = HKQuantityType(.stepCount)
        let startDate = Calendar.current.startOfDay(for: Date())
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: Date())

        return try await withCheckedThrowingContinuation { continuation in
            let query = HKStatisticsQuery(
                quantityType: steps,
                quantitySamplePredicate: predicate,
                options: .cumulativeSum
            ) { _, results, error in

                if let nsError = error as NSError?,
                   nsError.domain == "com.apple.healthkit",
                   nsError.code == 11 {
                    continuation.resume(returning: 0)
                    return
                }

                if let error {
                    continuation.resume(throwing: error)
                    return
                }

                let totalSteps = results?.sumQuantity()?.doubleValue(for: .count()) ?? 0
                continuation.resume(returning: Int(totalSteps.rounded()))
            }

            self.healthStore.execute(query)
        }
    }

    // MARK: - OLD (Apple Rings) — keep so your current UI doesn’t break
    func fetchExerciseTime() async throws -> Int {
        let exerciseTime = HKQuantityType(.appleExerciseTime)
        let startDate = Calendar.current.startOfDay(for: Date())
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: Date())

        return try await withCheckedThrowingContinuation { continuation in
            let query = HKStatisticsQuery(
                quantityType: exerciseTime,
                quantitySamplePredicate: predicate,
                options: .cumulativeSum
            ) { _, results, error in

                if let nsError = error as NSError?,
                   nsError.domain == "com.apple.healthkit",
                   nsError.code == 11 {
                    continuation.resume(returning: 0)
                    return
                }

                if let error {
                    continuation.resume(throwing: error)
                    return
                }

                let minutes = results?.sumQuantity()?.doubleValue(for: .minute()) ?? 0
                continuation.resume(returning: Int(minutes.rounded()))
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
                    continuation.resume(returning: 0)
                    return
                }

                if let error {
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

    // MARK: - NEW ✅ Workout Minutes Today (works for WHOOP / iPhone / Watch)
    func fetchWorkoutMinutesToday() async throws -> Int {
        let workoutType = HKObjectType.workoutType()
        let start = Calendar.current.startOfDay(for: Date())
        let predicate = HKQuery.predicateForSamples(withStart: start, end: Date(), options: .strictStartDate)

        return try await withCheckedThrowingContinuation { continuation in
            let sort = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)

            let query = HKSampleQuery(
                sampleType: workoutType,
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: [sort]
            ) { _, samples, error in

                if let nsError = error as NSError?,
                   nsError.domain == "com.apple.healthkit",
                   nsError.code == 11 {
                    continuation.resume(returning: 0)
                    return
                }

                if let error {
                    continuation.resume(throwing: error)
                    return
                }

                let workouts = (samples as? [HKWorkout]) ?? []
                let totalSeconds = workouts.reduce(0.0) { $0 + $1.duration }
                continuation.resume(returning: Int((totalSeconds / 60.0).rounded()))
            }

            self.healthStore.execute(query)
        }
    }

    // MARK: - NEW ✅ Sleep Last Night (minutes)
    func fetchSleepMinutesLastNight() async throws -> Int {
        guard let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) else { return 0 }

        let cal = Calendar.current
        let startOfToday = cal.startOfDay(for: Date())

        // window: yesterday 6pm -> today 12pm
        let start = cal.date(byAdding: .hour, value: -6, to: startOfToday)!
        let end = cal.date(byAdding: .hour, value: 12, to: startOfToday)!

        let predicate = HKQuery.predicateForSamples(withStart: start, end: end, options: .strictStartDate)
        let sort = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)

        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: sleepType,
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: [sort]
            ) { _, samples, error in

                if let nsError = error as NSError?,
                   nsError.domain == "com.apple.healthkit",
                   nsError.code == 11 {
                    continuation.resume(returning: 0)
                    return
                }

                if let error {
                    continuation.resume(throwing: error)
                    return
                }

                let items = (samples as? [HKCategorySample]) ?? []

                let asleepValues: Set<Int> = [
                    HKCategoryValueSleepAnalysis.asleepUnspecified.rawValue,
                    HKCategoryValueSleepAnalysis.asleepCore.rawValue,
                    HKCategoryValueSleepAnalysis.asleepDeep.rawValue,
                    HKCategoryValueSleepAnalysis.asleepREM.rawValue
                ]

                let asleepSeconds = items.reduce(0.0) { acc, s in
                    asleepValues.contains(s.value) ? acc + s.endDate.timeIntervalSince(s.startDate) : acc
                }

                if asleepSeconds > 0 {
                    continuation.resume(returning: Int((asleepSeconds / 60.0).rounded()))
                    return
                }

                // fallback: inBed
                let inBedSeconds = items.reduce(0.0) { acc, s in
                    s.value == HKCategoryValueSleepAnalysis.inBed.rawValue
                    ? acc + s.endDate.timeIntervalSince(s.startDate)
                    : acc
                }

                continuation.resume(returning: Int((inBedSeconds / 60.0).rounded()))
            }

            self.healthStore.execute(query)
        }
    }

    // MARK: - NEW ✅ Sleep Last 7 Days (for chart)
    func fetchSleepLast7Days() async throws -> [DailySleep] {
        guard let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) else { return [] }

        let cal = Calendar.current
        let endDate = Date()
        let startDay = cal.startOfDay(for: cal.date(byAdding: .day, value: -6, to: endDate)!)

        // Expand window to catch overnight sleep segments
        let start = cal.date(byAdding: .hour, value: -12, to: startDay)!
        let end = cal.date(byAdding: .hour, value: 12, to: cal.startOfDay(for: endDate))!

        let predicate = HKQuery.predicateForSamples(withStart: start, end: end, options: .strictStartDate)
        let sort = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)

        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: sleepType,
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: [sort]
            ) { _, samples, error in

                if let nsError = error as NSError?,
                   nsError.domain == "com.apple.healthkit",
                   nsError.code == 11 {
                    continuation.resume(returning: Self.zeroSleepWeek(from: startDay, calendar: cal))
                    return
                }

                if let error {
                    continuation.resume(throwing: error)
                    return
                }

                let items = (samples as? [HKCategorySample]) ?? []

                let asleepValues: Set<Int> = [
                    HKCategoryValueSleepAnalysis.asleepUnspecified.rawValue,
                    HKCategoryValueSleepAnalysis.asleepCore.rawValue,
                    HKCategoryValueSleepAnalysis.asleepDeep.rawValue,
                    HKCategoryValueSleepAnalysis.asleepREM.rawValue
                ]

                // group by the morning day (endDate day)
                var asleepByDay: [String: Double] = [:] // seconds
                var inBedByDay: [String: Double] = [:]

                for s in items {
                    let day = cal.startOfDay(for: s.endDate)
                    let id = Self.sleepDayID(day)
                    let seconds = s.endDate.timeIntervalSince(s.startDate)

                    if asleepValues.contains(s.value) {
                        asleepByDay[id, default: 0] += seconds
                    } else if s.value == HKCategoryValueSleepAnalysis.inBed.rawValue {
                        inBedByDay[id, default: 0] += seconds
                    }
                }

                let out: [DailySleep] = (0..<7).map { offset in
                    let d = cal.startOfDay(for: cal.date(byAdding: .day, value: offset, to: startDay)!)
                    let id = Self.sleepDayID(d)

                    let seconds = asleepByDay[id] ?? inBedByDay[id] ?? 0
                    let minutes = Int((seconds / 60.0).rounded())

                    return DailySleep(id: id, date: d, minutes: minutes)
                }

                continuation.resume(returning: out)
            }

            self.healthStore.execute(query)
        }
    }

    // Helpers (unique names so it won’t clash with your Steps extension helpers)
    private static func sleepDayID(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: date)
    }

    private static func zeroSleepWeek(from startDate: Date, calendar: Calendar) -> [DailySleep] {
        (0..<7).map { offset in
            let d = calendar.startOfDay(for: calendar.date(byAdding: .day, value: offset, to: startDate)!)
            return DailySleep(id: sleepDayID(d), date: d, minutes: 0)
        }
    }

    // MARK: - Workouts (your existing code)
    func fetchWorkoutsThisWeek() async throws -> [HKWorkout] {
        let workout = HKObjectType.workoutType()
        let startOfWeek = Calendar.current.dateInterval(of: .weekOfYear, for: Date())!.start
        let predicate = HKQuery.predicateForSamples(withStart: startOfWeek, end: Date())
        let sort = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)

        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: workout,
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: [sort]
            ) { _, result, error in
                if let nserror = error as NSError?, nserror.code == 11 {
                    continuation.resume(returning: [])
                    return
                }
                if let error {
                    continuation.resume(throwing: error)
                    return
                }
                continuation.resume(returning: (result as? [HKWorkout]) ?? [])
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

    func fetchRecentWorkouts(limit: Int = 10) async throws -> [WorkoutModel] {
        let workoutsType = HKObjectType.workoutType()
        let start = Calendar.current.date(byAdding: .day, value: -30, to: Date())
        let predicate = HKQuery.predicateForSamples(withStart: start, end: Date())
        let sort = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)

        let workouts: [HKWorkout] = try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: workoutsType,
                predicate: predicate,
                limit: limit,
                sortDescriptors: [sort]
            ) { _, results, error in

                if let nsError = error as NSError?,
                   nsError.domain == "com.apple.healthkit",
                   nsError.code == 11 {
                    continuation.resume(returning: [])
                    return
                }

                if let error {
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

// MARK: - Your existing HKWorkoutActivityType helpers
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


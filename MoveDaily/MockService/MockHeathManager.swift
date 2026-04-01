//
//  MockHeathManager.swift
//  MoveDaily
//
//  Created by Rachit Sharma on 31/03/2026.
//

import Foundation
import Foundation
import HealthKit

final class MockHealthManager: HealthManagerProtocol {
    
    var apperror:AppError?
    
    // MARK: - Authorization
    func requestHealthkitAccess() async throws {
        // do nothing
    }
    
    // MARK: - Calories
    func fetchBasalCaloriesBurned() async throws -> Double {
        1500
    }
    
    func fetchCaloriesBurned() async throws -> Double {
        if let apperror = apperror{
            throw apperror
        }
       return 550
    }
    
    // MARK: - Steps
    func fetchStepCount() async throws -> Int {
        8234
    }
    
    func fetchStepsLast7Days() async throws -> [DailySteps] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        return (0..<7).map { offset in
            let date = calendar.date(byAdding: .day, value: -6 + offset, to: today)!
            return DailySteps(
                id: "\(offset)",
                date: date,
                steps: Int.random(in: 4000...12000)
            )
        }
    }
    
    // MARK: - Apple Rings
    func fetchExerciseTime() async throws -> Int {
        45
    }
    
    func fetchTodayStandHours() async throws -> Int {
        10
    }
    
    // MARK: - Workout / Sleep
    func fetchWorkoutMinutesToday() async throws -> Int {
        60
    }
    
    func fetchSleepMinutesLastNight() async throws -> Int {
        420 // 7 hours
    }
    
    func fetchSleepLast7Days() async throws -> [DailySleep] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        return (0..<7).map { offset in
            let date = calendar.date(byAdding: .day, value: -6 + offset, to: today)!
            return DailySleep(
                id: "\(offset)",
                date: date,
                minutes: Int.random(in: 360...480)
            )
        }
    }
    
    // MARK: - Workouts
    func fetchWorkoutsThisWeek() async throws -> [HKWorkout] {
        []
    }
    
    func fetchWeeklyWorkoutMinutesByType() async throws -> [HKWorkoutActivityType : Int] {
        [
            .running: 40,
            .walking: 30,
            .cycling: 20
        ]
    }
    
    func fetchRecentWorkouts(limit: Int) async throws -> [WorkoutModel] {
        [
            WorkoutModel(
                id: UUID().uuidString,
                title: "Running",
                image: "figure.run",
                duration: "35 min",
                date: "31 Mar",
                calories: "300 kcal"
            ),
            WorkoutModel(
                id: UUID().uuidString,
                title: "Walking",
                image: "figure.walk",
                duration: "25 min",
                date: "30 Mar",
                calories: "120 kcal"
            )
        ]
    }
}

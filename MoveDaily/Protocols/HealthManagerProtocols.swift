//
//  HealthManagerp.swift
//  MoveDaily
//
//  Created by Rachit Sharma on 31/03/2026.
//

import Foundation
import HealthKit

protocol HealthManagerProtocol {
    
    // MARK: - Authorization
    func requestHealthkitAccess() async throws
    
    // MARK: - Calories
    func fetchBasalCaloriesBurned() async throws -> Double
    func fetchCaloriesBurned() async throws -> Double
    
    // MARK: - Steps
    func fetchStepCount() async throws -> Int
    func fetchStepsLast7Days() async throws -> [DailySteps] 
    
    // MARK: - Apple Rings / Old Metrics
    func fetchExerciseTime() async throws -> Int
    func fetchTodayStandHours() async throws -> Int
    
    // MARK: - Workout / Sleep
    func fetchWorkoutMinutesToday() async throws -> Int
    func fetchSleepMinutesLastNight() async throws -> Int
    func fetchSleepLast7Days() async throws -> [DailySleep]
    
    // MARK: - Workouts
    func fetchWorkoutsThisWeek() async throws -> [HKWorkout]
    func fetchWeeklyWorkoutMinutesByType() async throws -> [HKWorkoutActivityType: Int]
    func fetchRecentWorkouts(limit: Int) async throws -> [WorkoutModel]
}

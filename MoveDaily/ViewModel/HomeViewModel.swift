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
class HomeViewModel {
    var weeklySteps: [DailySteps] = []
    var totalCalories: Int = 0
    var calories: Int = 0
    var active: Int = 0
    var stand: Int = 0
    var error: AppError?

    var isloading: Bool = false
    private var hasRequestedAccess: Bool = false

    let healthManager: HealthManager

    init(healthManager: HealthManager) {
        self.healthManager = healthManager
    }

    var weeklyWorkoutData: [ActivityCard] = []
    var healthData: [ActivityCard] = []


    func loadHome() async {
        isloading = true
        defer { isloading = false }
        error = nil

        if !hasRequestedAccess {
            await requestToAccess()
            hasRequestedAccess = true
            if error != nil { return }
        }

        await fetchAll()
    }


    func refreshHome() async {
        error = nil
        await fetchAll()
    }

    private func fetchAll() async {
        async let weeklyStepsFunc: Void = fetchWeeklySteps()
        async let dashBoardFunc: Void = funcDashboard()
        async let weeklyWorkOutCardsFunc: Void = fetchWeeklyWorkoutCards()

        _ = await (weeklyStepsFunc, dashBoardFunc, weeklyWorkOutCardsFunc)
    }

    func fetchWeeklySteps() async {
        do {
            weeklySteps = try await healthManager.fetchStepsLast7Days()
        } catch {
            self.error = mapHealthKitError(error)
            weeklySteps = []
        }
    }

    func requestToAccess() async {
        do {
            guard HKHealthStore.isHealthDataAvailable() else {
                print("no data")
                return
            }
            try await healthManager.requestHealthkitAccess()
            print("healthManager called")
        } catch {
            print("Debug: error \(error.localizedDescription)")
            self.error = mapHealthKitError(error)
        }
    }

    func funcDashboard() async {
        do {
            async let activeCalories = healthManager.fetchCaloriesBurned()
            async let basalCalories = healthManager.fetchBasalCaloriesBurned()
            async let activeMins = healthManager.fetchExerciseTime()
            async let standHours = healthManager.fetchTodayStandHours()
            async let steps = healthManager.fetchStepCount()

            let (activeCals, basalCals, activeInt, standInt, stepsInt) =
                try await (activeCalories, basalCalories, activeMins, standHours, steps)

            calories = Int(activeCals.rounded())
            totalCalories = Int((activeCals + basalCals).rounded())
            active = activeInt
            stand = standInt

            healthData = [
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
                    amount: Int(activeCals.rounded()),
                    title: "Calories",
                    goal: 300,
                    image: "flame.fill",
                    color: .red
                )
            ]
        } catch {
            self.error = mapHealthKitError(error)
        }
    }

    func fetchWeeklyWorkoutCards() async {
        do {
            let minsByType = try await healthManager.fetchWeeklyWorkoutMinutesByType()

            func mins(_ type: HKWorkoutActivityType) -> Int {
                minsByType[type, default: 0]
            }

            weeklyWorkoutData = [
                ActivityCard(id: "wk_running", amount: mins(.running), title: "Running", goal: 150, image: "figure.run", color: .green),
                ActivityCard(id: "wk_strength", amount: mins(.traditionalStrengthTraining), title: "Strength", goal: 120, image: "dumbbell", color: .blue),
                ActivityCard(id: "wk_cycling", amount: mins(.cycling), title: "Cycling", goal: 120, image: "bicycle", color: .green),
                ActivityCard(id: "wk_soccer", amount: mins(.soccer), title: "Soccer", goal: 90, image: "figure.soccer", color: .indigo)
            ]
        } catch {
            self.error = mapHealthKitError(error)
            weeklyWorkoutData = []
        }
    }
}

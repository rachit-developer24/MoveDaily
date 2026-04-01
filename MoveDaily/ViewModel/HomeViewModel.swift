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

    // Existing
    var weeklySteps: [DailySteps] = []
    var totalCalories: Int = 0
    var calories: Int = 0
    var error: AppError?

    var isloading: Bool = false
    private var hasRequestedAccess: Bool = false

    let healthManager: HealthManagerProtocol

    var weeklyWorkoutData: [ActivityCard] = []
    var healthData: [ActivityCard] = []

    // ✅ New (WHOOP-friendly)
    var workoutMinutesToday: Int = 0
    var sleepMinutesLastNight: Int = 0
    var weeklySleep: [DailySleep] = []

    init(healthManager: HealthManagerProtocol) {
        self.healthManager = healthManager
    }

    // MARK: - Sleep UI helpers
    var sleepZone: SleepZone { SleepZone.from(minutes: sleepMinutesLastNight) }

    var sleepTint: Color {
        sleepMinutesLastNight > 0 ? sleepZone.color : .secondary
    }

    var sleepText: String {
        guard sleepMinutesLastNight > 0 else { return "Unavailable" }
        let h = sleepMinutesLastNight / 60
        let m = sleepMinutesLastNight % 60
        return "\(h)h \(m)m"
    }

    var sleepStatusText: String {
        sleepMinutesLastNight > 0 ? sleepZone.title : "Not available"
    }

    // MARK: - Lifecycle
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
        async let weeklySleepFunc: Void = fetchWeeklySleep()
        async let dashBoardFunc: Void = funcDashboard()
        async let weeklyWorkOutCardsFunc: Void = fetchWeeklyWorkoutCards()

        _ = await (weeklyStepsFunc, weeklySleepFunc, dashBoardFunc, weeklyWorkOutCardsFunc)
    }

    // MARK: - Authorization
    func requestToAccess() async {
        do {
            guard HKHealthStore.isHealthDataAvailable() else {
                self.error = .healthDataNotAvailable
                return
            }
            try await healthManager.requestHealthkitAccess()
        } catch {
            self.error = mapHealthKitError(error)
        }
    }

    // MARK: - Weekly Steps
    func fetchWeeklySteps() async {
        do {
            weeklySteps = try await healthManager.fetchStepsLast7Days()
        } catch {
            self.error = mapHealthKitError(error)
            weeklySteps = []
        }
    }

    // MARK: - Weekly Sleep
    func fetchWeeklySleep() async {
        do {
            weeklySleep = try await healthManager.fetchSleepLast7Days()
        } catch {
            self.error = mapHealthKitError(error)
            weeklySleep = []
        }
    }

    // MARK: - Dashboard
    func funcDashboard() async {
        do {
            async let activeCalories = healthManager.fetchCaloriesBurned()
            async let basalCalories = healthManager.fetchBasalCaloriesBurned()
            async let workoutMins = healthManager.fetchWorkoutMinutesToday()
            async let sleepMins = healthManager.fetchSleepMinutesLastNight()
            async let steps = healthManager.fetchStepCount()

            let (activeCals, basalCals, workoutInt, sleepInt, stepsInt) =
                try await (activeCalories, basalCalories, workoutMins, sleepMins, steps)

            calories = Int(activeCals.rounded())
            totalCalories = Int((activeCals + basalCals).rounded())

            workoutMinutesToday = workoutInt
            sleepMinutesLastNight = sleepInt

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

    // MARK: - Weekly workout cards
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

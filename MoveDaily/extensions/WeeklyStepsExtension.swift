//
//  WeeklyStepsExtension.swift
//  MoveDaily
//
//  Created by Rachit Sharma on 01/03/2026.
//

import Foundation
import HealthKit

extension HealthManager {

    func fetchStepsLast7Days() async throws -> [DailySteps] {
        let stepsType = HKQuantityType(.stepCount)

        let calendar = Calendar.current
        let endDate = Date()

        // Start of day 6 days ago => 7 days including today
        let startDate = calendar.startOfDay(
            for: calendar.date(byAdding: .day, value: -6, to: endDate)!
        )

        // Daily buckets
        var interval = DateComponents()
        interval.day = 1

        // Align buckets to midnight
        let anchorDate = calendar.startOfDay(for: endDate)

        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate)

        return try await withCheckedThrowingContinuation { continuation in
            let query = HKStatisticsCollectionQuery(
                quantityType: stepsType,
                quantitySamplePredicate: predicate,
                options: .cumulativeSum,
                anchorDate: anchorDate,
                intervalComponents: interval
            )

            query.initialResultsHandler = { _, results, error in
                if let nsError = error as NSError?,
                   nsError.domain == "com.apple.healthkit",
                   nsError.code == 11 {
                    continuation.resume(returning: Self.zeroStepsWeek(from: startDate, calendar: calendar))
                    return
                }

                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }

                guard let results else {
                    continuation.resume(returning: Self.zeroStepsWeek(from: startDate, calendar: calendar))
                    return
                }

                var output: [DailySteps] = []

                results.enumerateStatistics(from: startDate, to: endDate) { stats, _ in
                    let value = stats.sumQuantity()?.doubleValue(for: .count()) ?? 0
                    let dayStart = calendar.startOfDay(for: stats.startDate)

                    output.append(
                        DailySteps(
                            id: Self.dayID(dayStart),
                            date: dayStart,
                            steps: Int(value.rounded())
                        )
                    )
                }

                continuation.resume(
                    returning: Self.normalizeToSevenDays(output, startDate: startDate, calendar: calendar)
                )
            }

            self.healthStore.execute(query)
        }
    }

    // MARK: - Helpers

    private static func dayID(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: date)
    }

    private static func zeroStepsWeek(from startDate: Date, calendar: Calendar) -> [DailySteps] {
        (0..<7).map { offset in
            let d = calendar.date(byAdding: .day, value: offset, to: startDate)!
            let day = calendar.startOfDay(for: d)
            return DailySteps(id: dayID(day), date: day, steps: 0)
        }
    }

    private static func normalizeToSevenDays(
        _ input: [DailySteps],
        startDate: Date,
        calendar: Calendar
    ) -> [DailySteps] {

        var map: [String: DailySteps] = [:]
        for item in input { map[item.id] = item }

        return (0..<7).map { offset in
            let d = calendar.date(byAdding: .day, value: offset, to: startDate)!
            let day = calendar.startOfDay(for: d)
            let id = dayID(day)
            return map[id] ?? DailySteps(id: id, date: day, steps: 0)
        }
    }
}

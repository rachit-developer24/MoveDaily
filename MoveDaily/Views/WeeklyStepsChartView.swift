//
//  PastDataView.swift
//  MoveDaily
//
//  Created by Rachit Sharma on 17/02/2026.
//

import SwiftUI
import Charts

struct WeeklyStepsChartView: View {
    let data: [DailySteps]

    private let dayFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = .current
        f.dateFormat = "E" // Mon, Tue...
        return f
    }()

    private var totalSteps: Int {
        data.map(\.steps).reduce(0, +)
    }

    private var averageSteps: Int {
        guard !data.isEmpty else { return 0 }
        return totalSteps / data.count
    }

    private var bestDay: DailySteps? {
        data.max(by: { $0.steps < $1.steps })
    }

    private var maxSteps: Int {
        data.map(\.steps).max() ?? 0
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {

                // Header
                VStack(alignment: .leading, spacing: 6) {
                    Text("Weekly Steps")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Text("Last 7 days")
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal)

                // Stat cards row
                HStack(spacing: 12) {
                    StatCard(title: "Total", value: "\(totalSteps)", subtitle: "steps", systemImage: "sum")

                    StatCard(title: "Average", value: "\(averageSteps)", subtitle: "per day", systemImage: "chart.bar.fill")
                }
                .padding(.horizontal)

                // Best day card (optional but makes the screen feel complete)
                if let bestDay {
                    StatCard(
                        title: "Best day",
                        value: "\(bestDay.steps)",
                        subtitle: dayFormatter.string(from: bestDay.date),
                        systemImage: "star.fill"
                    )
                    .padding(.horizontal)
                }

                // Chart card
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Steps chart")
                            .font(.title3)
                            .fontWeight(.semibold)
                        Spacer()
                    }

                    if data.isEmpty {
                        Text("No steps data yet.")
                            .foregroundStyle(.secondary)
                            .padding(.vertical, 24)
                    } else {
                        Chart(data) { item in
                            BarMark(
                                x: .value("Day", item.date),
                                y: .value("Steps", item.steps)
                            )
                            .cornerRadius(4)
                        }
                        .chartXAxis {
                            AxisMarks(values: .stride(by: .day)) { value in
                                AxisGridLine()
                                AxisTick()
                                AxisValueLabel {
                                    if let date = value.as(Date.self) {
                                        Text(dayFormatter.string(from: date))
                                    }
                                }
                            }
                        }
                        .chartYAxis {
                            AxisMarks(position: .leading)
                        }
                        // Helps when values are small / large
                        .chartYScale(domain: 0...max(maxSteps, 1000))
                        .frame(height: 220)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding(.horizontal)

                Spacer(minLength: 8)
            }
            .padding(.top, 8)
        }
    }
}

// MARK: - Small reusable stat card
private struct StatCard: View {
    let title: String
    let value: String
    let subtitle: String
    let systemImage: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: systemImage)
                .imageScale(.large)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)

                Text(subtitle)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

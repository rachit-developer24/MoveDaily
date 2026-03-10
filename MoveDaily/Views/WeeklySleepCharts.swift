//
//  WeeklySleepCharts.swift
//  MoveDaily
//
//  Created by Rachit Sharma on 05/03/2026.
//

import SwiftUI
import Charts

struct WeeklySleepChartView: View {
    let data: [DailySleep]

    struct SleepChartItem: Identifiable {
        let date: Date
        let hours: Double
        let hasData: Bool

        var id: Date { date }
    }

    private let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = .current
        formatter.dateFormat = "E"
        return formatter
    }()

    private var chartData: [SleepChartItem] {
        let calendar = Calendar.current

        let groupedSleep = Dictionary(grouping: data) { item in
            calendar.startOfDay(for: item.date)
        }.mapValues { items in
            items.reduce(0.0) { result, item in
                result + Double(item.minutes) / 60.0
            }
        }

        let today = calendar.startOfDay(for: Date())

        return (0..<7).compactMap { offset in
            guard let date = calendar.date(byAdding: .day, value: -offset, to: today) else {
                return nil
            }

            let startOfDay = calendar.startOfDay(for: date)
            let hours = groupedSleep[startOfDay] ?? 0

            return SleepChartItem(
                date: startOfDay,
                hours: hours,
                hasData: groupedSleep[startOfDay] != nil
            )
        }
        .reversed()
    }

    private var totalHours: Double {
        chartData.map(\.hours).reduce(0, +)
    }

    private var averageHours: Double {
        guard !chartData.isEmpty else { return 0 }
        return totalHours / Double(chartData.count)
    }

    private var maxHours: Double {
        max(8, chartData.map(\.hours).max() ?? 8)
    }

    private var hasAnySleepData: Bool {
        chartData.contains(where: { $0.hasData })
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {

                VStack(alignment: .leading, spacing: 6) {
                    Text("Weekly Sleep")
                        .font(.largeTitle.bold())

                    Text("Last 7 days")
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal)

                HStack(spacing: 12) {
                    StatCard(
                        title: "Total",
                        value: String(format: "%.1f", totalHours),
                        subtitle: "hours",
                        systemImage: "sum"
                    )

                    StatCard(
                        title: "Average",
                        value: String(format: "%.1f", averageHours),
                        subtitle: "per night",
                        systemImage: "bed.double.fill"
                    )
                }
                .padding(.horizontal)

                VStack(alignment: .leading, spacing: 12) {
                    Text("Sleep chart")
                        .font(.title3.weight(.semibold))

                    if !hasAnySleepData {
                        Text("No sleep data yet.")
                            .foregroundStyle(.secondary)
                            .padding(.vertical, 24)
                    } else {
                        Chart(chartData) { item in
                            BarMark(
                                x: .value("Day", item.date),
                                y: .value("Hours", item.hasData ? item.hours : 0.15)
                            )
                            .cornerRadius(4)
                            .opacity(item.hasData ? 1.0 : 0.25)
                            .annotation(position: .top) {
                                if !item.hasData {
                                    Text("No data")
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                        .chartXAxis {
                            AxisMarks(values: .stride(by: .day)) { value in
                                AxisValueLabel {
                                    if let date = value.as(Date.self) {
                                        Text(dayFormatter.string(from: date))
                                    }
                                }
                            }
                        }
                        .chartYScale(domain: 0...maxHours)
                        .frame(height: 220)

                        Text("Missing days may mean no sleep was recorded in Apple Health.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding(.horizontal)
            }
            .padding(.top, 8)
        }
    }
}

#Preview {
    WeeklySleepChartView(
        data: [
            DailySleep(id: "1", date: Date(), minutes: 420),
            DailySleep(id: "2", date: Calendar.current.date(byAdding: .day, value: -1, to: Date())!, minutes: 360),
            DailySleep(id: "3", date: Calendar.current.date(byAdding: .day, value: -3, to: Date())!, minutes: 510),
            DailySleep(id: "4", date: Calendar.current.date(byAdding: .day, value: -5, to: Date())!, minutes: 470)
        ]
    )
}

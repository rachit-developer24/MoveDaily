//
//  WeeklySleepCharts.swift
//  MoveDaily
//
//  Created by Rachit Sharma on 05/03/2026.
//

import SwiftUI
import SwiftUI
import Charts

struct WeeklySleepChartView: View {
    let data: [DailySleep]

    private let dayFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = .current
        f.dateFormat = "E"
        return f
    }()

    private var hoursData: [(date: Date, hours: Double)] {
        data.map { ($0.date, Double($0.minutes) / 60.0) }
    }

    private var totalHours: Double { hoursData.map(\.hours).reduce(0, +) }

    private var averageHours: Double {
        guard !hoursData.isEmpty else { return 0 }
        return totalHours / Double(hoursData.count)
    }

    private var maxHours: Double { max(8, hoursData.map(\.hours).max() ?? 8) }

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
                    StatCard(title: "Total", value: String(format: "%.1f", totalHours), subtitle: "hours", systemImage: "sum")
                    StatCard(title: "Average", value: String(format: "%.1f", averageHours), subtitle: "per night", systemImage: "bed.double.fill")
                }
                .padding(.horizontal)

                VStack(alignment: .leading, spacing: 12) {
                    Text("Sleep chart")
                        .font(.title3.weight(.semibold))

                    if data.isEmpty {
                        Text("No sleep data yet.")
                            .foregroundStyle(.secondary)
                            .padding(.vertical, 24)
                    } else {
                        Chart(hoursData, id: \.date) { item in
                            BarMark(
                                x: .value("Day", item.date),
                                y: .value("Hours", item.hours)
                            )
                            .cornerRadius(4)
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
    WeeklySleepChartView(data:[DailySleep(id: "aa", date:Date(), minutes: 400)])
}

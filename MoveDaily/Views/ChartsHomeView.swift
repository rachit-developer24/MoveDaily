//
//  ChartsHomeView.swift
//  MoveDaily
//
//  Created by Rachit Sharma on 05/03/2026.
//

import SwiftUI

struct ChartsHomeView: View {
    @Environment(HomeViewModel.self) var homeViewModel

    enum ChartKind: String, CaseIterable, Identifiable {
        case steps = "Steps"
        case sleep = "Sleep"
        var id: String { rawValue }
    }

    @State private var selected: ChartKind = .steps

    var body: some View {
        VStack(spacing: 12) {

            Picker("Chart", selection: $selected) {
                ForEach(ChartKind.allCases) { kind in
                    Text(kind.rawValue).tag(kind)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            .padding(.top, 8)

            switch selected {
            case .steps:
                WeeklyStepsChartView(data: homeViewModel.weeklySteps)

            case .sleep:
                WeeklySleepChartView(data: homeViewModel.weeklySleep)
            }
        }
    }
}
#Preview {
    ChartsHomeView()
}

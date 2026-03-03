//
//  HomeView.swift
//  MoveDaily
//
//  Created by Rachit Sharma on 17/02/2026.
//

import SwiftUI

struct HomeView: View {
    @Environment(HomeViewModel.self) var homeViewModel
    @Environment(WorkoutViewModel.self) var workOutViewModel

    private let grid = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    private var todayString: String {
        let f = DateFormatter()
        f.dateFormat = "EEEE, d MMM"
        return f.string(from: Date())
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()

                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 16) {


                        VStack(alignment: .leading, spacing: 6) {
                            Text(todayString)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)

                            Text("MoveDaily")
                                .font(.largeTitle.bold())
                        }
                        .padding(.horizontal)
                        .padding(.top, 8)

                
                        Card {
                            HStack(alignment: .center, spacing: 16) {

                                VStack(alignment: .leading, spacing: 10) {
                                    MetricRow(title: "Total Calories", value: totalCaloriesText, tint: .red)

                                    MetricRow(title: "Active Calories", value: "\(homeViewModel.calories) kcal", tint: .pink)

                                    MetricRow(title: "Exercise", value: "\(homeViewModel.active) min", tint: .green)

                                    MetricRow(title: "Stand", value: "\(homeViewModel.stand) hr", tint: .blue)

                                    if homeViewModel.totalCalories == 0 {
                                        Text("Total calories depend on Resting Energy data in Apple Health.")
                                            .font(.footnote)
                                            .foregroundStyle(.secondary)
                                            .padding(.top, 6)
                                    }
                                }

                                Spacer()

                                ZStack {
                                    ProgressCircleView(progress: homeViewModel.calories, goal: 600, color: .red)
                                    ProgressCircleView(progress: homeViewModel.active, goal: 60, color: .green)
                                        .padding(18)
                                    ProgressCircleView(progress: homeViewModel.stand, goal: 12, color: .blue)
                                        .padding(36)
                                }
                                .frame(width: 140, height: 140)
                            }
                        }
                        .padding(.horizontal)

      
                        SectionHeader(title: "Fitness Activity")
                            .padding(.horizontal)

                        LazyVGrid(columns: grid, spacing: 12) {
                            ForEach(homeViewModel.healthData) { item in
                                FitnessActivityCard(activityCard: item)
                            }
                        }
                        .padding(.horizontal)

        
                        SectionHeader(title: "This Week")
                            .padding(.horizontal)

                        LazyVGrid(columns: grid, spacing: 12) {
                            ForEach(homeViewModel.weeklyWorkoutData) { item in
                                FitnessActivityCard(activityCard: item)
                            }
                        }
                        .padding(.horizontal)


                        HStack {
                            SectionHeader(title: "Recent Workouts")
                            Spacer()

                            // keep your NavigationLink when you build the full list screen
                            NavigationLink {
                                EmptyView()
                            } label: {
                                Text("See all")
                                    .font(.subheadline.weight(.semibold))
                            }
                            .foregroundStyle(.green)
                        }
                        .padding(.horizontal)

                        Card {
                            if workOutViewModel.workouts.isEmpty {
                                Text("No workouts yet.")
                                    .foregroundStyle(.secondary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            } else {
                                VStack(spacing: 12) {
                                    ForEach(workOutViewModel.workouts) { workout in
                                        WorkoutCard(workout: workout)

                                        if workout.id != workOutViewModel.workouts.last?.id {
                                            Divider()
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)

                        Spacer(minLength: 10)
                    }
                    .padding(.bottom, 16)
                }
                if let error = homeViewModel.error {

                    Color.black.opacity(0.3)
                        .ignoresSafeArea()

                    VStack(spacing: 16) {

                        Text("Something went wrong")
                            .font(.headline)

                        Text(error.localizedDescription)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.secondary)

                        Button("Try Again") {
                            Task {
                                await homeViewModel.loadHome()
                            }
                        }
                        .buttonStyle(.borderedProminent)

                        if error == .notAuthorized {
                            Button("Open Settings") {
                                if let url = URL(string: UIApplication.openSettingsURLString) {
                                    UIApplication.shared.open(url)
                                }
                            }
                        }
                    }
                    .padding()
                    .frame(maxWidth: 320)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                }


                if homeViewModel.isloading {
                    Color.black.opacity(0.08).ignoresSafeArea()
                    HomeLoadingView()
                        .transition(.opacity)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
        .refreshable {
            await homeViewModel.refreshHome()
            await workOutViewModel.fetchWorkouts()
        }
        .task {
            await homeViewModel.loadHome()
            await workOutViewModel.fetchWorkouts()
        }
    }

    private var totalCaloriesText: String {
        homeViewModel.totalCalories > 0 ? "\(homeViewModel.totalCalories) kcal" : "Unavailable"
    }
}





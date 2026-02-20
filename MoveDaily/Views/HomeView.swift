//
//  HomeView.swift
//  MoveDaily
//
//  Created by Rachit Sharma on 17/02/2026.
//

import SwiftUI

struct HomeView: View {
    @State var calories:Int = 200
    @State var active:Int = 34
    @State var stand:Int = 6
    @Environment(HomeViewModel.self) var homeViewModel
    @State private var workoutViewModel = WorkoutViewModel()
    var griditem:[GridItem] = [
        .init(.flexible(),spacing: 1),
        .init(.flexible(),spacing: 1)
    ]
    var body: some View {
        NavigationStack {
            ScrollView{
                VStack(alignment:.leading,spacing: 35){
                    Text("Welcome")
                        .font(Font.largeTitle)
                        .padding(.horizontal)
                    HStack{
                        VStack{
                            VStack(alignment:.leading,spacing:16){
                                Text("calories")
                                    .fontWeight(.bold)
                                    .foregroundStyle(.pink)
                                Text("\(homeViewModel.calories) calories")
                                    .fontWeight(.semibold)
                                
                                Text("Active")
                                    .fontWeight(.bold)
                                    .foregroundStyle(.green)
                                Text("\(homeViewModel.active) minutes")
                                    .fontWeight(.semibold)
                                Text("Stand")
                                    .fontWeight(.bold)
                                    .foregroundStyle(.blue)
                                Text("\(homeViewModel.stand) hours")
                                    .fontWeight(.semibold)
                            }
                            
                        }
                        Spacer()
                        ZStack{
                            ProgressCircleView(progress: $calories, goal: 600, color: .red)
                            ProgressCircleView(progress: $active, goal: 60, color: .green)
                                .padding(20)
                            ProgressCircleView(progress: $stand, goal: 12, color: .blue)
                                .padding(40)
                            
                        }
                        .padding(.horizontal)
                        .frame(height: 220)
                        
                        
                    }.padding()
                    HStack{
                        Text("Fitness Activity")
                            .font(.title2)
                        Spacer()
                        Button {
                            print("show More")
                        } label: {
                            Text("show more")
                                .padding(.all,10)
                                .background(Color.blue)
                                .foregroundStyle(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        
                    }
                    .padding(.horizontal)
                    LazyVGrid(columns: griditem, content: {
                        ForEach(homeViewModel.healthData) { healthcard in
                            FitnessActivityCard(activityCard: healthcard)
                        }
                    })
                    .padding(.horizontal)
                   
                        HStack{
                            Text("Recent Workouts")
                                .font(.title2)
                            Spacer()
                            NavigationLink {
                                EmptyView()
                            } label: {
                                Text("show more")
                                    .padding(.all,10)
                                    .background(Color.blue)
                                    .foregroundStyle(.white)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                        }
                        .padding(.horizontal)
                    LazyVStack{
                        ForEach(workoutViewModel.workouts){ workout in  WorkoutCard(workout: workout)
                            
                        }
                    }
                    
                }
                .task{
                    await homeViewModel.requestToAccess()
                    await workoutViewModel.fetchWorkouts()
                    await homeViewModel.fetchHealthData()
                    await homeViewModel.funcDashboard()
                   
                }
               
            }
           
        }
       
           
      
    }
}

#Preview {
    HomeView()
        .environment(HomeViewModel(healthManager: HealthManager()))
}

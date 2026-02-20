//
//  WorkoutCard.swift
//  MoveDaily
//
//  Created by Rachit Sharma on 17/02/2026.
//

import SwiftUI

struct WorkoutCard: View {
    let workout:WorkoutModel
    var body: some View {
        HStack{
            Image(systemName: workout.image)
                .resizable()
                .scaledToFit()
                .frame(width: 48, height: 48)
                .padding()
                .background(Color(.systemGray6))
                .foregroundStyle(.green)
            VStack(alignment:.leading,spacing: 15){
                Text(workout.title)
                    .fontWeight(.semibold)
                Text(workout.date)
            }
            Spacer()
            VStack(alignment:.leading,spacing: 15){
                Text(workout.duration)
                Text(workout.calories)
            }
        }
        .padding(.horizontal)
    }
}

#Preview {
    WorkoutCard(workout: WorkoutModel(id: "1", title: "Running", image: "running", duration: "30 min", date: "2026-02-17", calories: "200"))
}

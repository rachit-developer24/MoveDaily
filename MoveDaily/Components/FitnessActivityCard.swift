//
//  FitnessActivityCard.swift
//  MoveDaily
//
//  Created by Rachit Sharma on 17/02/2026.
//

import SwiftUI

struct FitnessActivityCard: View {
    let activityCard:ActivityCard
    var body: some View {
        VStack(spacing:20){
            HStack(alignment:.top){
                VStack(alignment:.leading){
                    Text(activityCard.title)
                    Text("Goal \(activityCard.goal)")
                        .foregroundStyle(.gray)
                        .font(.footnote)
            }
                Spacer()
                Image(systemName: activityCard.image)
                    .foregroundStyle(activityCard.color)
                
            }
            .padding(.horizontal)
            Text("\(activityCard.steps)")
                .font(.title)
            
        }.frame(width: 180, height: 150)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    FitnessActivityCard(activityCard: ActivityCard(id: "abc", steps: 1200, title: "Today steps", goal: 10000, image: "walking.man", color: .green))
}

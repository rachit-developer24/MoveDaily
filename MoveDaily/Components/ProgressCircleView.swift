//
//  ProgressCircleView.swift
//  MoveDaily
//
//  Created by Rachit Sharma on 17/02/2026.
//

import SwiftUI

struct ProgressCircleView: View {
    @Binding var progress:Int
    var goal:Int
    var color:Color
    var width:CGFloat = 20
    var body: some View {
        ZStack{
            Circle()
                .stroke(color.opacity(0.3), lineWidth: 20)
            Circle()
                .trim(from: 0, to:CGFloat(progress)/CGFloat(goal))
                .rotation(.degrees(-90))
                .stroke(color,style:StrokeStyle(lineWidth:width,lineCap:.round))
                .shadow(radius:5)
                
        }
    }
}

#Preview {
   ProgressCircleView(progress: .constant(100), goal: 200, color: .red)
}

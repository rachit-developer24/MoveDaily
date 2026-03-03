//
//  ProgressCircleView.swift
//  MoveDaily
//
//  Created by Rachit Sharma on 17/02/2026.
//

import SwiftUI

struct ProgressCircleView: View {
    var progress: Int
    var goal: Int
    var color: Color
    var width: CGFloat = 20

    private var fraction: CGFloat {
        guard goal > 0 else { return 0 }
        return min(max(CGFloat(progress) / CGFloat(goal), 0), 1)
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(color.opacity(0.3), lineWidth: width)

            Circle()
                .trim(from: 0, to: fraction)
                .stroke(
                    color,
                    style: StrokeStyle(lineWidth: width, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .shadow(radius: 5)
                .animation(Animation.easeInOut(duration: 0.4), value: progress)
        }
    }
}

#Preview {
    ProgressCircleView(progress: 255, goal: 200, color: .red)
}




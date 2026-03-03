//
//  LoadingHomeView.swift
//  MoveDaily
//
//  Created by Rachit Sharma on 02/03/2026.
//

import SwiftUI

struct HomeLoadingView: View {
    @State private var isAnimating = false

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "figure.run")
                .font(.system(size: 44, weight: .semibold))
                .rotationEffect(.degrees(isAnimating ? 360 : 0))
                .animation(.linear(duration: 1.0).repeatForever(autoreverses: false), value: isAnimating)

            Text("Loading health data...")
                .font(.headline)

            Text("This can take a moment.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
        .onAppear { isAnimating = true }
        .onDisappear { isAnimating = false }
    }
}

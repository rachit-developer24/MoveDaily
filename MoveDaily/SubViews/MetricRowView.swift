//
//  MetricRowView.swift
//  MoveDaily
//
//  Created by Rachit Sharma on 03/03/2026.
//

import SwiftUI

struct MetricRow: View {
    let title: String
    let value: String
    let tint: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(tint)

            Text(value)
                .font(.headline.weight(.semibold))
                .foregroundStyle(.primary)
        }
    }
}

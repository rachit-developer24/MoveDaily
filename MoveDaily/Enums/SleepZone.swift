//
//  SleepZone.swift
//  MoveDaily
//
//  Created by Rachit Sharma on 05/03/2026.
//

import Foundation
import SwiftUI

enum SleepZone {
    case red, yellow, green

    var title: String {
        switch self {
        case .red: return "Low"
        case .yellow: return "Okay"
        case .green: return "Great"
        }
    }

    var color: Color {
        switch self {
        case .red: return .red
        case .yellow: return .yellow
        case .green: return .green
        }
    }

    static func from(minutes: Int) -> SleepZone {
        let hours = Double(minutes) / 60.0

        if hours < 5 { return .red }
        if hours < 7 { return .yellow }
        return .green
    }
}

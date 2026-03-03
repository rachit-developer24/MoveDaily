//
//  DailyStepsModel.swift
//  MoveDaily
//
//  Created by Rachit Sharma on 01/03/2026.
//

import Foundation

struct DailySteps: Identifiable, Equatable {
    let id: String     
    let date: Date
    let steps: Int
}

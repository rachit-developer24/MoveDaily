//
//  AppError.swift
//  MoveDaily
//
//  Created by Rachit Sharma on 03/03/2026.
//

import Foundation
import HealthKit



enum AppError: LocalizedError, Equatable {
    case healthDataNotAvailable
    case notAuthorized
    case noData
    case healthKit
    case unknown(String)

    var errorDescription: String? {
        switch self {
        case .healthDataNotAvailable:
            return "Health data isn’t available on this device."

        case .notAuthorized:
            return "Health access is not granted. Please allow access in Settings."

        case .noData:
            return "No health data found for today yet."

        case .healthKit:
            return "HealthKit returned an error. Please try again."

        case .unknown(let message):
            return message
        }
    }
   
}

func mapHealthKitError(_ error: Error) -> AppError {

    if let hkError = error as? HKError {

        switch hkError.code {

        case .errorAuthorizationDenied:
            return .notAuthorized

        case .errorHealthDataUnavailable:
            return .healthDataNotAvailable

        case .errorNoData:
            return .noData

        default:
            return .healthKit
        }
    }

    let nsError = error as NSError

    if nsError.domain == HKErrorDomain,
       nsError.code == HKError.errorNoData.rawValue {
        return .noData
    }

    return .unknown(error.localizedDescription)
}


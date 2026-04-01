//
//  MoveDailyTests.swift
//  MoveDaily Health TrackerTests
//
//  Created by Rachit Sharma on 31/03/2026.
//

import XCTest
@testable import MoveDaily_Health_Tracker
@MainActor
final class MoveDailyTests: XCTestCase {
    
    var healthManager:MockHealthManager!
    var homeViewModel:HomeViewModel!
  
    
    override func setUp() async throws {
        try await super.setUp()
        healthManager = MockHealthManager()
        homeViewModel = HomeViewModel(healthManager: healthManager)
        
    }
    
    override func tearDown() async throws {
        healthManager = nil
        homeViewModel = nil
        try await super.tearDown()
    }

    
    func testCalories()async{
        await homeViewModel.funcDashboard()
        XCTAssertEqual(homeViewModel.calories, 550)
    }
    
    
    func testCaloriesError()async{
        healthManager.apperror = .noData
         await homeViewModel.funcDashboard()
        XCTAssertNotNil(homeViewModel.error)
    }
    
    

}

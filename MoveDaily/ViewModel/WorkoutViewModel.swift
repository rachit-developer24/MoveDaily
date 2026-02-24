//
//  WorkoutViewModel.swift
//  MoveDaily
//
//  Created by Rachit Sharma on 17/02/2026.
//

import Foundation
@Observable
class WorkoutViewModel{
    var error:Error?
    let service:HealthManager
    init(service:HealthManager){
        self.service = service
    }
    
   var workouts: [WorkoutModel] = []
    
    
    func fetchWorkouts()async{
        do{
            self.workouts = try await service.fetchRecentWorkouts()
        }catch{
            self.error = error
        }
    }
}

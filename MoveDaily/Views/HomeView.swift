//
//  HomeView.swift
//  MoveDaily
//
//  Created by Rachit Sharma on 17/02/2026.
//

import SwiftUI

struct HomeView: View {
    @State var calories:Int = 200
    @State var active:Int = 34
    @State var stand:Int = 6
    var body: some View {
        VStack(spacing: 35){
            Text("Welcome")
                .font(Font.largeTitle)
            HStack{
                VStack{
                    VStack(alignment:.leading,spacing:16){
                        Text("calories")
                            .fontWeight(.bold)
                            .foregroundStyle(.pink)
                        Text("123 calories")
                            .fontWeight(.semibold)
                        
                        Text("Active")
                            .fontWeight(.bold)
                            .foregroundStyle(.green)
                        Text("52 minutes")
                            .fontWeight(.semibold)
                        Text("Stand")
                            .fontWeight(.bold)
                            .foregroundStyle(.blue)
                        Text("123 calories")
                            .fontWeight(.semibold)
                    }
                    
                }
                Spacer()
                ZStack{
                    ProgressCircleView(progress: $calories, goal: 600, color: .red)
                    ProgressCircleView(progress: $active, goal: 60, color: .green)
                        .padding(20)
                    ProgressCircleView(progress: $stand, goal: 12, color: .blue)
                        .padding(40)
                    
                }
                .padding(.horizontal)
                .frame(height: 220)
                
                
            }.padding()
           
        }
        Spacer()
        
        
      
    }
}

#Preview {
    HomeView()
}

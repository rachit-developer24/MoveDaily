//
//  MoveDailyMainTabView.swift
//  MoveDaily
//
//  Created by Rachit Sharma on 17/02/2026.
//

import SwiftUI

struct MoveDailyMainTabView: View {
    @State var selectedTab = "Home"
    var body: some View {
            TabView(selection: $selectedTab) {
                HomeView()
                    .tag("Home")
                    .tabItem{
                        Image(systemName: "house")
                        Text("Home")
                    }
                
                PastDataView()
                    .tag("PastData")
                    .tabItem {
                        Image(systemName: "chart.line.uptrend.xyaxis")
                        Text("Charts")
                    }
            }
            .tint(.green)
        }
}

#Preview {
    MoveDailyMainTabView()
}

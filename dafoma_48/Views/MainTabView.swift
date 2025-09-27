//
//  MainTabView.swift
//  Habitally Dom
//
//  Created by Вячеслав on 9/27/25.
//

import SwiftUI

struct MainTabView: View {
    @StateObject private var dataManager = DataManager.shared
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HabitsView()
                .tabItem {
                    Image(systemName: selectedTab == 0 ? "checkmark.circle.fill" : "checkmark.circle")
                    Text("Habits")
                }
                .tag(0)
            
            GoalsView()
                .tabItem {
                    Image(systemName: selectedTab == 1 ? "target" : "scope")
                    Text("Goals")
                }
                .tag(1)
            
            RoutinesView()
                .tabItem {
                    Image(systemName: selectedTab == 2 ? "clock.fill" : "clock")
                    Text("Routines")
                }
                .tag(2)
            
            MindfulnessView()
                .tabItem {
                    Image(systemName: selectedTab == 3 ? "leaf.fill" : "leaf")
                    Text("Mindfulness")
                }
                .tag(3)
            
            SettingsView()
                .tabItem {
                    Image(systemName: selectedTab == 4 ? "gearshape.fill" : "gearshape")
                    Text("Settings")
                }
                .tag(4)
        }
        .accentColor(Color(hex: "#2DCC72"))
        .environmentObject(dataManager)
    }
}

#Preview {
    MainTabView()
}

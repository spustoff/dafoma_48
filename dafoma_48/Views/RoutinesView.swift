//
//  RoutinesView.swift
//  Habitally Dom
//
//  Created by Вячеслав on 9/27/25.
//

import SwiftUI

struct RoutinesView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var showingAddRoutine = false
    @State private var selectedRoutine: Routine?
    @State private var showingTemplates = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.white.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header with stats
                    headerView
                    
                    if dataManager.routines.isEmpty {
                        emptyStateView
                    } else {
                        routinesList
                    }
                }
            }
            .navigationTitle("Routines")
            .navigationBarTitleDisplayMode(.large)
            .navigationBarItems(trailing: 
                Menu {
                    Button(action: { showingAddRoutine = true }) {
                        Label("Create Custom Routine", systemImage: "plus.circle")
                    }
                    
                    Button(action: { showingTemplates = true }) {
                        Label("Use Template", systemImage: "doc.text")
                    }
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundColor(Color(hex: "#2DCC72"))
                }
            )
        }
        .sheet(isPresented: $showingAddRoutine) {
            AddRoutineView()
        }
        .sheet(isPresented: $showingTemplates) {
            RoutineTemplatesView()
        }
        .sheet(item: $selectedRoutine) { routine in
            RoutineDetailView(routine: routine)
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 16) {
            HStack(spacing: 20) {
                StatCard(
                    title: "Active Routines",
                    value: "\(dataManager.routines.filter { $0.isActive }.count)",
                    icon: "clock.fill",
                    color: "#2DCC72"
                )
                
                StatCard(
                    title: "Completed Today",
                    value: "\(routinesCompletedToday)",
                    icon: "checkmark.circle.fill",
                    color: "#45B7D1"
                )
                
                StatCard(
                    title: "Best Streak",
                    value: "\(bestRoutineStreak)",
                    icon: "flame.fill",
                    color: "#FF6B6B"
                )
            }
            .padding(.horizontal)
        }
        .padding(.vertical)
        .background(Color.gray.opacity(0.05))
    }
    
    private var routinesList: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(Routine.TimeOfDay.allCases, id: \.self) { timeOfDay in
                    let routinesForTime = dataManager.routines.filter { $0.timeOfDay == timeOfDay && $0.isActive }
                    
                    if !routinesForTime.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: timeOfDay.icon)
                                    .font(.title3)
                                    .foregroundColor(Color(hex: timeOfDay.color))
                                
                                Text(timeOfDay.rawValue)
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.black)
                                
                                Spacer()
                            }
                            .padding(.horizontal)
                            
                            ForEach(routinesForTime) { routine in
                                RoutineCard(routine: routine) {
                                    selectedRoutine = routine
                                }
                            }
                        }
                    }
                }
            }
            .padding(.horizontal)
            .padding(.top)
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(Color(hex: "#4ECDC4").opacity(0.1))
                    .frame(width: 120, height: 120)
                
                Image(systemName: "clock")
                    .font(.system(size: 50))
                    .foregroundColor(Color(hex: "#4ECDC4"))
            }
            
            VStack(spacing: 12) {
                Text("Build Your Perfect Day")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                
                Text("Create personalized routines that structure your day and help you stay consistent with your goals.")
                    .font(.body)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            VStack(spacing: 12) {
                Button(action: { showingTemplates = true }) {
                    HStack {
                        Image(systemName: "doc.text")
                        Text("Start with Template")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color(hex: "#4ECDC4"))
                    .cornerRadius(25)
                }
                
                Button(action: { showingAddRoutine = true }) {
                    HStack {
                        Image(systemName: "plus")
                        Text("Create Custom Routine")
                    }
                    .font(.subheadline)
                    .foregroundColor(Color(hex: "#4ECDC4"))
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color(hex: "#4ECDC4"), lineWidth: 2)
                    )
                }
            }
            
            Spacer()
        }
    }
    
    private var routinesCompletedToday: Int {
        return dataManager.routines.filter { $0.isCompletedForDate(Date()) }.count
    }
    
    private var bestRoutineStreak: Int {
        return dataManager.routines.map { $0.currentStreak() }.max() ?? 0
    }
}

struct RoutineCard: View {
    let routine: Routine
    let onTap: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(routine.name)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.black)
                        
                        Spacer()
                        
                        if routine.isCompletedForDate(Date()) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.title3)
                                .foregroundColor(Color(hex: "#2DCC72"))
                        }
                    }
                    
                    Text(routine.description)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .lineLimit(2)
                    
                    HStack {
                        HStack(spacing: 4) {
                            Image(systemName: "clock")
                                .font(.caption)
                                .foregroundColor(.gray)
                            Text("\(routine.estimatedDuration) min")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        
                        HStack(spacing: 4) {
                            Image(systemName: "list.bullet")
                                .font(.caption)
                                .foregroundColor(.gray)
                            Text("\(routine.activities.count) activities")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                        
                        HStack(spacing: 4) {
                            Image(systemName: "flame.fill")
                                .font(.caption)
                                .foregroundColor(.orange)
                            Text("\(routine.currentStreak())")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.orange)
                        }
                    }
                }
                
                Spacer()
            }
            .padding()
            
            // Activities preview
            if !routine.activities.isEmpty {
                VStack(spacing: 6) {
                    HStack {
                        Text("Activities")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.gray)
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    ForEach(routine.activities.prefix(3), id: \.id) { activity in
                        HStack {
                            Circle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: 6, height: 6)
                            
                            Text(activity.name)
                                .font(.caption)
                                .foregroundColor(.gray)
                            
                            Spacer()
                            
                            Text("\(activity.estimatedMinutes) min")
                                .font(.caption2)
                                .foregroundColor(.gray)
                        }
                        .padding(.horizontal)
                    }
                    
                    if routine.activities.count > 3 {
                        HStack {
                            Text("+ \(routine.activities.count - 3) more activities")
                                .font(.caption2)
                                .foregroundColor(.gray)
                            
                            Spacer()
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.bottom)
            }
        }
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        .onTapGesture {
            onTap()
        }
    }
}

#Preview {
    RoutinesView()
        .environmentObject(DataManager.shared)
}

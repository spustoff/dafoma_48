//
//  HabitsView.swift
//  Habitally Dom
//
//  Created by Вячеслав on 9/27/25.
//

import SwiftUI

struct HabitsView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var showingAddHabit = false
    @State private var selectedHabit: Habit?
    @State private var showingHabitDetail = false
    @State private var completedHabitMessage: String?
    @State private var showingCompletionMessage = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.white.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header with stats
                    headerView
                    
                    if dataManager.habits.isEmpty {
                        emptyStateView
                    } else {
                        habitsList
                    }
                }
            }
            .navigationTitle("Habits")
            .navigationBarTitleDisplayMode(.large)
            .navigationBarItems(trailing: 
                Button(action: { showingAddHabit = true }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundColor(Color(hex: "#2DCC72"))
                }
            )
        }
        .sheet(isPresented: $showingAddHabit) {
            AddHabitView()
        }
        .sheet(item: $selectedHabit) { habit in
            HabitDetailView(habit: habit)
        }
        .alert("Great Job!", isPresented: $showingCompletionMessage) {
            Button("Continue") { }
        } message: {
            Text(completedHabitMessage ?? "")
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 16) {
            HStack(spacing: 20) {
                StatCard(
                    title: "Active Habits",
                    value: "\(dataManager.habits.filter { $0.isActive }.count)",
                    icon: "checkmark.circle.fill",
                    color: "#2DCC72"
                )
                
                StatCard(
                    title: "Today's Progress",
                    value: "\(Int(todayCompletionRate * 100))%",
                    icon: "chart.line.uptrend.xyaxis",
                    color: "#45B7D1"
                )
                
                StatCard(
                    title: "Best Streak",
                    value: "\(bestStreak)",
                    icon: "flame.fill",
                    color: "#FF6B6B"
                )
            }
            .padding(.horizontal)
        }
        .padding(.vertical)
        .background(Color.gray.opacity(0.05))
    }
    
    private var habitsList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(dataManager.habits.filter { $0.isActive }) { habit in
                    HabitCard(
                        habit: habit,
                        onComplete: { completeHabit(habit) },
                        onTap: { 
                            selectedHabit = habit
                            showingHabitDetail = true
                        }
                    )
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
                    .fill(Color(hex: "#2DCC72").opacity(0.1))
                    .frame(width: 120, height: 120)
                
                Image(systemName: "checkmark.circle")
                    .font(.system(size: 50))
                    .foregroundColor(Color(hex: "#2DCC72"))
            }
            
            VStack(spacing: 12) {
                Text("Start Building Great Habits")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                
                Text("Create your first habit and begin your journey toward a better you. Small steps lead to big changes.")
                    .font(.body)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            Button(action: { showingAddHabit = true }) {
                HStack {
                    Image(systemName: "plus")
                    Text("Add Your First Habit")
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(Color(hex: "#2DCC72"))
                .cornerRadius(25)
            }
            
            Spacer()
        }
    }
    
    private var todayCompletionRate: Double {
        let activeHabits = dataManager.habits.filter { $0.isActive }
        guard !activeHabits.isEmpty else { return 0 }
        
        let completedToday = activeHabits.filter { $0.isCompletedForDate(Date()) }.count
        return Double(completedToday) / Double(activeHabits.count)
    }
    
    private var bestStreak: Int {
        return dataManager.habits.map { $0.currentStreak() }.max() ?? 0
    }
    
    private func completeHabit(_ habit: Habit) {
        dataManager.completeHabit(withId: habit.id)
        completedHabitMessage = habit.motivationalMessage
        showingCompletionMessage = true
        
        // Haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
    }
}

struct HabitCard: View {
    let habit: Habit
    let onComplete: () -> Void
    let onTap: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: habit.category.icon)
                            .font(.title3)
                            .foregroundColor(Color(hex: habit.category.color))
                        
                        Text(habit.name)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.black)
                        
                        Spacer()
                        
                        if habit.isCompletedForDate(Date()) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.title2)
                                .foregroundColor(Color(hex: "#2DCC72"))
                        }
                    }
                    
                    Text(habit.description)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .lineLimit(2)
                    
                    HStack {
                        Text("\(habit.targetFrequency) \(habit.frequencyType.description)")
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        Spacer()
                        
                        HStack(spacing: 4) {
                            Image(systemName: "flame.fill")
                                .font(.caption)
                                .foregroundColor(.orange)
                            Text("\(habit.currentStreak())")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.orange)
                        }
                    }
                }
                
                Spacer()
            }
            .padding()
            
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 4)
                    
                    Rectangle()
                        .fill(Color(hex: "#2DCC72"))
                        .frame(width: geometry.size.width * habit.progressForDate(Date()), height: 4)
                        .animation(.easeInOut(duration: 0.3), value: habit.progressForDate(Date()))
                }
            }
            .frame(height: 4)
        }
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        .onTapGesture {
            onTap()
        }
        .contextMenu {
            if !habit.isCompletedForDate(Date()) {
                Button(action: onComplete) {
                    Label("Mark Complete", systemImage: "checkmark.circle")
                }
            }
            
            Button(action: onTap) {
                Label("View Details", systemImage: "info.circle")
            }
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(Color(hex: color))
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.black)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

#Preview {
    HabitsView()
        .environmentObject(DataManager.shared)
}

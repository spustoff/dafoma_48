//
//  GoalsView.swift
//  Habitally Dom
//
//  Created by Вячеслав on 9/27/25.
//

import SwiftUI

struct GoalsView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var showingAddGoal = false
    @State private var selectedGoal: Goal?
    @State private var selectedSegment = 0
    
    private let segments = ["Active", "Completed"]
    
    var activeGoals: [Goal] {
        dataManager.goals.filter { !$0.isCompleted }.sorted { goal1, goal2 in
            if goal1.priority.sortOrder != goal2.priority.sortOrder {
                return goal1.priority.sortOrder < goal2.priority.sortOrder
            }
            return goal1.targetDate < goal2.targetDate
        }
    }
    
    var completedGoals: [Goal] {
        dataManager.goals.filter { $0.isCompleted }.sorted { $0.createdDate > $1.createdDate }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.white.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header with stats
                    headerView
                    
                    // Segment control
                    segmentControl
                    
                    // Goals list
                    if selectedSegment == 0 {
                        if activeGoals.isEmpty {
                            emptyActiveGoalsView
                        } else {
                            activeGoalsList
                        }
                    } else {
                        if completedGoals.isEmpty {
                            emptyCompletedGoalsView
                        } else {
                            completedGoalsList
                        }
                    }
                }
            }
            .navigationTitle("Goals")
            .navigationBarTitleDisplayMode(.large)
            .navigationBarItems(trailing: 
                Button(action: { showingAddGoal = true }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundColor(Color(hex: "#2DCC72"))
                }
            )
        }
        .sheet(isPresented: $showingAddGoal) {
            AddGoalView()
        }
        .sheet(item: $selectedGoal) { goal in
            GoalDetailView(goal: goal)
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 16) {
            HStack(spacing: 20) {
                StatCard(
                    title: "Active Goals",
                    value: "\(activeGoals.count)",
                    icon: "target",
                    color: "#2DCC72"
                )
                
                StatCard(
                    title: "Completed",
                    value: "\(completedGoals.count)",
                    icon: "checkmark.circle.fill",
                    color: "#45B7D1"
                )
                
                StatCard(
                    title: "Success Rate",
                    value: "\(successRate)%",
                    icon: "chart.line.uptrend.xyaxis",
                    color: "#FF6B6B"
                )
            }
            .padding(.horizontal)
        }
        .padding(.vertical)
        .background(Color.gray.opacity(0.05))
    }
    
    private var segmentControl: some View {
        Picker("Goals", selection: $selectedSegment) {
            ForEach(0..<segments.count, id: \.self) { index in
                Text(segments[index]).tag(index)
            }
        }
        .pickerStyle(SegmentedPickerStyle())
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
    
    private var activeGoalsList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(activeGoals) { goal in
                    GoalCard(goal: goal) {
                        selectedGoal = goal
                    }
                }
            }
            .padding(.horizontal)
            .padding(.top)
        }
    }
    
    private var completedGoalsList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(completedGoals) { goal in
                    CompletedGoalCard(goal: goal) {
                        selectedGoal = goal
                    }
                }
            }
            .padding(.horizontal)
            .padding(.top)
        }
    }
    
    private var emptyActiveGoalsView: some View {
        VStack(spacing: 24) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(Color(hex: "#45B7D1").opacity(0.1))
                    .frame(width: 120, height: 120)
                
                Image(systemName: "target")
                    .font(.system(size: 50))
                    .foregroundColor(Color(hex: "#45B7D1"))
            }
            
            VStack(spacing: 12) {
                Text("Set Your First Goal")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                
                Text("Transform your dreams into achievable goals. Break them down into milestones and watch your progress unfold.")
                    .font(.body)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            Button(action: { showingAddGoal = true }) {
                HStack {
                    Image(systemName: "plus")
                    Text("Create Your First Goal")
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(Color(hex: "#45B7D1"))
                .cornerRadius(25)
            }
            
            Spacer()
        }
    }
    
    private var emptyCompletedGoalsView: some View {
        VStack(spacing: 24) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(Color.gray.opacity(0.1))
                    .frame(width: 120, height: 120)
                
                Image(systemName: "checkmark.circle")
                    .font(.system(size: 50))
                    .foregroundColor(.gray)
            }
            
            VStack(spacing: 12) {
                Text("No Completed Goals Yet")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                
                Text("Keep working on your active goals. Completed goals will appear here as you achieve them.")
                    .font(.body)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            Spacer()
        }
    }
    
    private var successRate: Int {
        let totalGoals = dataManager.goals.count
        guard totalGoals > 0 else { return 0 }
        let completedCount = completedGoals.count
        return Int((Double(completedCount) / Double(totalGoals)) * 100)
    }
}

struct GoalCard: View {
    let goal: Goal
    let onTap: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: goal.category.icon)
                            .font(.title3)
                            .foregroundColor(Color(hex: goal.category.color))
                        
                        Text(goal.title)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.black)
                        
                        Spacer()
                        
                        PriorityBadge(priority: goal.priority)
                    }
                    
                    Text(goal.description)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .lineLimit(2)
                    
                    HStack {
                        HStack(spacing: 4) {
                            Image(systemName: "calendar")
                                .font(.caption)
                                .foregroundColor(.gray)
                            Text(formatDate(goal.targetDate))
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                        
                        if goal.isOverdue {
                            Text("Overdue")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.red)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(Color.red.opacity(0.1))
                                .cornerRadius(8)
                        } else {
                            Text("\(goal.daysRemaining) days left")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                }
                
                Spacer()
            }
            .padding()
            
            // Progress bar
            VStack(spacing: 8) {
                HStack {
                    Text("Progress")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    Spacer()
                    
                    Text("\(Int(goal.progress * 100))%")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.black)
                }
                .padding(.horizontal)
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 6)
                            .cornerRadius(3)
                        
                        Rectangle()
                            .fill(Color(hex: "#2DCC72"))
                            .frame(width: geometry.size.width * goal.progress, height: 6)
                            .cornerRadius(3)
                            .animation(.easeInOut(duration: 0.3), value: goal.progress)
                    }
                }
                .frame(height: 6)
                .padding(.horizontal)
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
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

struct CompletedGoalCard: View {
    let goal: Goal
    let onTap: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title3)
                        .foregroundColor(Color(hex: "#2DCC72"))
                    
                    Text(goal.title)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.black)
                    
                    Spacer()
                }
                
                Text(goal.description)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .lineLimit(2)
                
                HStack {
                    Text(goal.category.rawValue)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(Color(hex: goal.category.color))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color(hex: goal.category.color).opacity(0.1))
                        .cornerRadius(8)
                    
                    Spacer()
                    
                    Text("Completed")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(Color(hex: "#2DCC72"))
                }
            }
            
            Spacer()
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        .onTapGesture {
            onTap()
        }
    }
}

struct PriorityBadge: View {
    let priority: Goal.Priority
    
    var body: some View {
        Text(priority.rawValue)
            .font(.caption2)
            .fontWeight(.bold)
            .foregroundColor(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 2)
            .background(Color(hex: priority.color))
            .cornerRadius(8)
    }
}

#Preview {
    GoalsView()
        .environmentObject(DataManager.shared)
}

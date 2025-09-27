//
//  HabitDetailView.swift
//  Habitally Dom
//
//  Created by Вячеслав on 9/27/25.
//

import SwiftUI

struct HabitDetailView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var dataManager: DataManager
    @State var habit: Habit
    @State private var showingEditView = false
    @State private var showingDeleteAlert = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.white.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        headerView
                        
                        // Stats cards
                        statsView
                        
                        // Progress chart
                        progressChartView
                        
                        // Recent completions
                        recentCompletionsView
                        
                        Spacer(minLength: 100)
                    }
                    .padding()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Done") {
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(Color(hex: "#2DCC72")),
                trailing: Menu {
                    Button(action: { showingEditView = true }) {
                        Label("Edit Habit", systemImage: "pencil")
                    }
                    
                    Button(role: .destructive, action: { showingDeleteAlert = true }) {
                        Label("Delete Habit", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .foregroundColor(.gray)
                }
            )
        }
        .sheet(isPresented: $showingEditView) {
            EditHabitView(habit: $habit)
        }
        .alert("Delete Habit", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                dataManager.deleteHabit(withId: habit.id)
                presentationMode.wrappedValue.dismiss()
            }
        } message: {
            Text("Are you sure you want to delete this habit? This action cannot be undone.")
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 16) {
            // Icon and category
            ZStack {
                Circle()
                    .fill(Color(hex: habit.category.color))
                    .frame(width: 80, height: 80)
                
                Image(systemName: habit.category.icon)
                    .font(.system(size: 35))
                    .foregroundColor(.white)
            }
            
            VStack(spacing: 8) {
                Text(habit.name)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                
                Text(habit.description)
                    .font(.body)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                
                HStack {
                    Text(habit.category.rawValue)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(Color(hex: habit.category.color))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(Color(hex: habit.category.color).opacity(0.1))
                        .cornerRadius(12)
                    
                    Text("\(habit.targetFrequency) \(habit.frequencyType.description)")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.gray)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(12)
                }
            }
        }
    }
    
    private var statsView: some View {
        VStack(spacing: 16) {
            Text("Statistics")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.black)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: 16) {
                StatDetailCard(
                    title: "Current Streak",
                    value: "\(habit.currentStreak())",
                    subtitle: "days",
                    icon: "flame.fill",
                    color: "#FF6B6B"
                )
                
                StatDetailCard(
                    title: "Total Completions",
                    value: "\(habit.completions.count)",
                    subtitle: "times",
                    icon: "checkmark.circle.fill",
                    color: "#2DCC72"
                )
            }
            
            HStack(spacing: 16) {
                StatDetailCard(
                    title: "This Week",
                    value: "\(completionsThisWeek)",
                    subtitle: "completed",
                    icon: "calendar.badge.checkmark",
                    color: "#45B7D1"
                )
                
                StatDetailCard(
                    title: "Success Rate",
                    value: "\(Int(successRate * 100))%",
                    subtitle: "last 30 days",
                    icon: "chart.line.uptrend.xyaxis",
                    color: "#FFEAA7"
                )
            }
        }
    }
    
    private var progressChartView: some View {
        VStack(spacing: 16) {
            Text("7-Day Progress")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.black)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: 8) {
                ForEach((0..<7).reversed(), id: \.self) { dayOffset in
                    let date = Calendar.current.date(byAdding: .day, value: -dayOffset, to: Date()) ?? Date()
                    let isCompleted = habit.isCompletedForDate(date)
                    let progress = habit.progressForDate(date)
                    
                    VStack(spacing: 8) {
                        Text(dayAbbreviation(for: date))
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.gray)
                        
                        ZStack {
                            Circle()
                                .fill(Color.gray.opacity(0.2))
                                .frame(width: 32, height: 32)
                            
                            Circle()
                                .fill(isCompleted ? Color(hex: "#2DCC72") : Color(hex: "#2DCC72").opacity(progress))
                                .frame(width: 32, height: 32)
                            
                            if isCompleted {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.white)
                            }
                        }
                        
                        Text("\(Calendar.current.component(.day, from: date))")
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding()
            .background(Color.gray.opacity(0.05))
            .cornerRadius(16)
        }
    }
    
    private var recentCompletionsView: some View {
        VStack(spacing: 16) {
            Text("Recent Activity")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.black)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            if habit.completions.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "clock")
                        .font(.title2)
                        .foregroundColor(.gray)
                    
                    Text("No completions yet")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    Text("Complete this habit to see your progress here")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }
                .padding(.vertical, 32)
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(habit.completions.suffix(10).reversed(), id: \.id) { completion in
                        CompletionRow(completion: completion)
                    }
                }
            }
        }
    }
    
    private var completionsThisWeek: Int {
        let calendar = Calendar.current
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: Date())?.start ?? Date()
        
        return habit.completions.filter { completion in
            completion.completedDate >= startOfWeek
        }.count
    }
    
    private var successRate: Double {
        let calendar = Calendar.current
        let daysInPeriod = 30
        var completedDays = 0
        
        for dayOffset in 0..<daysInPeriod {
            if let date = calendar.date(byAdding: .day, value: -dayOffset, to: Date()),
               habit.isCompletedForDate(date) {
                completedDays += 1
            }
        }
        
        return Double(completedDays) / Double(daysInPeriod)
    }
    
    private func dayAbbreviation(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        return formatter.string(from: date)
    }
}

struct StatDetailCard: View {
    let title: String
    let value: String
    let subtitle: String
    let icon: String
    let color: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(Color(hex: color))
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.black)
            
            VStack(spacing: 2) {
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.black)
                
                Text(subtitle)
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

struct CompletionRow: View {
    let completion: HabitCompletion
    
    var body: some View {
        HStack {
            Image(systemName: "checkmark.circle.fill")
                .font(.title3)
                .foregroundColor(Color(hex: "#2DCC72"))
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Completed")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.black)
                
                Text(formatDate(completion.completedDate))
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            if let notes = completion.notes, !notes.isEmpty {
                Text(notes)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .lineLimit(2)
                    .multilineTextAlignment(.trailing)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

#Preview {
    HabitDetailView(habit: Habit(name: "Drink Water", description: "Stay hydrated", category: .health))
        .environmentObject(DataManager.shared)
}

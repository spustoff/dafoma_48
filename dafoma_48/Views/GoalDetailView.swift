//
//  GoalDetailView.swift
//  Habitally Dom
//
//  Created by Вячеслав on 9/27/25.
//

import SwiftUI

struct GoalDetailView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var dataManager: DataManager
    @State var goal: Goal
    @State private var showingDeleteAlert = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.white.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        headerView
                        
                        // Progress section
                        progressSection
                        
                        // Milestones
                        milestonesSection
                        
                        // Actions
                        if !goal.isCompleted {
                            actionsSection
                        }
                        
                        Spacer(minLength: 100)
                    }
                    .padding()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(Color(hex: "#2DCC72"))
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        if !goal.isCompleted {
                            Button(action: { completeGoal() }) {
                                Label("Mark Complete", systemImage: "checkmark.circle")
                            }
                        }
                        
                        Button(role: .destructive, action: { showingDeleteAlert = true }) {
                            Label("Delete Goal", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .foregroundColor(.gray)
                    }
                }
            }
        }
        .alert("Delete Goal", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                dataManager.deleteGoal(withId: goal.id)
                presentationMode.wrappedValue.dismiss()
            }
        } message: {
            Text("Are you sure you want to delete this goal? This action cannot be undone.")
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 16) {
            // Icon and category
            ZStack {
                Circle()
                    .fill(Color(hex: goal.category.color))
                    .frame(width: 80, height: 80)
                
                Image(systemName: goal.category.icon)
                    .font(.system(size: 35))
                    .foregroundColor(.white)
            }
            
            VStack(spacing: 8) {
                Text(goal.title)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                
                Text(goal.description)
                    .font(.body)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                
                HStack(spacing: 12) {
                    Text(goal.category.rawValue)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(Color(hex: goal.category.color))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(Color(hex: goal.category.color).opacity(0.1))
                        .cornerRadius(12)
                    
                    PriorityBadge(priority: goal.priority)
                    
                    if goal.isCompleted {
                        Text("Completed")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(Color(hex: "#2DCC72"))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 4)
                            .background(Color(hex: "#2DCC72").opacity(0.1))
                            .cornerRadius(12)
                    } else if goal.isOverdue {
                        Text("Overdue")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.red)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 4)
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(12)
                    }
                }
            }
        }
    }
    
    private var progressSection: some View {
        VStack(spacing: 16) {
            Text("Progress")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.black)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: 12) {
                // Progress bar
                VStack(spacing: 8) {
                    HStack {
                        Text("Overall Progress")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        
                        Spacer()
                        
                        Text("\(Int(goal.progress * 100))%")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.black)
                    }
                    
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .fill(Color.gray.opacity(0.2))
                                .frame(height: 8)
                                .cornerRadius(4)
                            
                            Rectangle()
                                .fill(Color(hex: "#2DCC72"))
                                .frame(width: geometry.size.width * goal.progress, height: 8)
                                .cornerRadius(4)
                                .animation(.easeInOut(duration: 0.3), value: goal.progress)
                        }
                    }
                    .frame(height: 8)
                }
                
                // Stats
                HStack(spacing: 16) {
                    StatDetailCard(
                        title: "Days Remaining",
                        value: goal.isCompleted ? "0" : "\(goal.daysRemaining)",
                        subtitle: goal.isOverdue ? "overdue" : "days left",
                        icon: "calendar",
                        color: goal.isOverdue ? "#E74C3C" : "#45B7D1"
                    )
                    
                    StatDetailCard(
                        title: "Milestones",
                        value: "\(goal.milestones.filter { $0.isCompleted }.count)/\(goal.milestones.count)",
                        subtitle: "completed",
                        icon: "flag.fill",
                        color: "#2DCC72"
                    )
                }
            }
        }
    }
    
    private var milestonesSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Milestones")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.black)
                
                Spacer()
                
                if let nextMilestone = goal.nextMilestone {
                    Text("Next: \(nextMilestone.title)")
                        .font(.caption)
                        .foregroundColor(Color(hex: "#2DCC72"))
                }
            }
            
            if goal.milestones.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "flag")
                        .font(.title2)
                        .foregroundColor(.gray)
                    
                    Text("No milestones set")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    Text("Break down your goal into smaller, achievable milestones")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }
                .padding(.vertical, 32)
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(goal.milestones.sorted { $0.targetDate < $1.targetDate }, id: \.id) { milestone in
                        MilestoneRow(milestone: milestone) {
                            toggleMilestone(milestone)
                        }
                    }
                }
            }
        }
    }
    
    private var actionsSection: some View {
        VStack(spacing: 12) {
            Button(action: { completeGoal() }) {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                    Text("Mark Goal as Complete")
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color(hex: "#2DCC72"))
                .cornerRadius(12)
            }
            
        }
    }
    
    private func completeGoal() {
        goal.isCompleted = true
        dataManager.updateGoal(goal)
        
        // Haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
    }
    
    private func toggleMilestone(_ milestone: Milestone) {
        if let index = goal.milestones.firstIndex(where: { $0.id == milestone.id }) {
            goal.milestones[index].isCompleted.toggle()
            if goal.milestones[index].isCompleted {
                goal.milestones[index].completedDate = Date()
            } else {
                goal.milestones[index].completedDate = nil
            }
            dataManager.updateGoal(goal)
        }
    }
}

struct MilestoneRow: View {
    let milestone: Milestone
    let onToggle: () -> Void
    
    var body: some View {
        HStack {
            Button(action: onToggle) {
                Image(systemName: milestone.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundColor(milestone.isCompleted ? Color(hex: "#2DCC72") : .gray)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(milestone.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.black)
                    .strikethrough(milestone.isCompleted)
                
                HStack {
                    Text(formatDate(milestone.targetDate))
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    if milestone.isOverdue && !milestone.isCompleted {
                        Text("• Overdue")
                            .font(.caption)
                            .foregroundColor(.red)
                    } else if milestone.isCompleted, let completedDate = milestone.completedDate {
                        Text("• Completed \(formatDate(completedDate))")
                            .font(.caption)
                            .foregroundColor(Color(hex: "#2DCC72"))
                    }
                }
            }
            
            Spacer()
        }
        .padding()
        .background(milestone.isCompleted ? Color(hex: "#2DCC72").opacity(0.05) : Color.gray.opacity(0.05))
        .cornerRadius(12)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}


#Preview {
    GoalDetailView(goal: Goal(title: "Test Goal", description: "Test description", category: .personal, targetDate: Date()))
        .environmentObject(DataManager.shared)
}

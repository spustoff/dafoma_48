//
//  AddGoalView.swift
//  Habitally Dom
//
//  Created by Вячеслав on 9/27/25.
//

import SwiftUI

struct AddGoalView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var dataManager: DataManager
    
    @State private var title = ""
    @State private var description = ""
    @State private var selectedCategory = Goal.GoalCategory.personal
    @State private var targetDate = Calendar.current.date(byAdding: .month, value: 1, to: Date()) ?? Date()
    @State private var priority = Goal.Priority.medium
    @State private var milestones: [String] = [""]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.white.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        VStack(spacing: 8) {
                            Text("Create New Goal")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.black)
                            
                            Text("Set an ambitious goal and break it into achievable milestones")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top)
                        
                        VStack(spacing: 20) {
                            // Title field
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Goal Title")
                                    .font(.headline)
                                    .foregroundColor(.black)
                                
                                TextField("e.g., Learn Spanish fluently", text: $title)
                                    .textFieldStyle(CustomTextFieldStyle())
                            }
                            
                            // Description field
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Description")
                                    .font(.headline)
                                    .foregroundColor(.black)
                                
                                TextField("Why is this goal important to you?", text: $description)
                                    .textFieldStyle(CustomTextFieldStyle())
                            }
                            
                            // Category selection
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Category")
                                    .font(.headline)
                                    .foregroundColor(.black)
                                
                                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                                    ForEach(Goal.GoalCategory.allCases, id: \.self) { category in
                                        GoalCategoryCard(
                                            category: category,
                                            isSelected: selectedCategory == category
                                        ) {
                                            selectedCategory = category
                                        }
                                    }
                                }
                            }
                            
                            // Priority and target date
                            HStack(spacing: 16) {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Priority")
                                        .font(.headline)
                                        .foregroundColor(.black)
                                    
                                    Picker("Priority", selection: $priority) {
                                        ForEach(Goal.Priority.allCases, id: \.self) { priority in
                                            Text(priority.rawValue).tag(priority)
                                        }
                                    }
                                    .pickerStyle(MenuPickerStyle())
                                    .padding()
                                    .background(Color.gray.opacity(0.1))
                                    .cornerRadius(12)
                                }
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Target Date")
                                        .font(.headline)
                                        .foregroundColor(.black)
                                    
                                    DatePicker("", selection: $targetDate, in: Date()..., displayedComponents: .date)
                                        .datePickerStyle(CompactDatePickerStyle())
                                        .padding()
                                        .background(Color.gray.opacity(0.1))
                                        .cornerRadius(12)
                                }
                            }
                            
                            // Milestones
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Text("Milestones (Optional)")
                                        .font(.headline)
                                        .foregroundColor(.black)
                                    
                                    Spacer()
                                    
                                    Button(action: addMilestone) {
                                        Image(systemName: "plus.circle.fill")
                                            .foregroundColor(Color(hex: "#2DCC72"))
                                    }
                                }
                                
                                ForEach(milestones.indices, id: \.self) { index in
                                    HStack {
                                        TextField("Milestone \(index + 1)", text: $milestones[index])
                                            .textFieldStyle(CustomTextFieldStyle())
                                        
                                        if milestones.count > 1 {
                                            Button(action: { removeMilestone(at: index) }) {
                                                Image(systemName: "minus.circle.fill")
                                                    .foregroundColor(.red)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                        Spacer(minLength: 100)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(.gray),
                trailing: Button("Create") {
                    createGoal()
                }
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isFormValid ? Color(hex: "#2DCC72") : Color.gray)
                .cornerRadius(20)
                .disabled(!isFormValid)
            )
        }
    }
    
    private var isFormValid: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    private func addMilestone() {
        milestones.append("")
    }
    
    private func removeMilestone(at index: Int) {
        milestones.remove(at: index)
    }
    
    private func createGoal() {
        var goal = Goal(
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            description: description.trimmingCharacters(in: .whitespacesAndNewlines),
            category: selectedCategory,
            targetDate: targetDate,
            priority: priority
        )
        
        // Add milestones
        let validMilestones = milestones.compactMap { milestone in
            let trimmed = milestone.trimmingCharacters(in: .whitespacesAndNewlines)
            return trimmed.isEmpty ? nil : trimmed
        }
        
        for (index, milestoneTitle) in validMilestones.enumerated() {
            let milestoneDate = Calendar.current.date(
                byAdding: .day,
                value: (index + 1) * 7, // Space milestones a week apart
                to: Date()
            ) ?? Date()
            
            let milestone = Milestone(
                title: milestoneTitle,
                description: "Milestone \(index + 1) for \(goal.title)",
                targetDate: min(milestoneDate, targetDate)
            )
            
            goal.addMilestone(milestone)
        }
        
        dataManager.addGoal(goal)
        presentationMode.wrappedValue.dismiss()
    }
}

struct GoalCategoryCard: View {
    let category: Goal.GoalCategory
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: category.icon)
                .font(.title2)
                .foregroundColor(isSelected ? .white : Color(hex: category.color))
            
            Text(category.rawValue)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(isSelected ? .white : .black)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(isSelected ? Color(hex: category.color) : Color.gray.opacity(0.1))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isSelected ? Color(hex: category.color) : Color.clear, lineWidth: 2)
        )
        .onTapGesture {
            onTap()
        }
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}

#Preview {
    AddGoalView()
        .environmentObject(DataManager.shared)
}

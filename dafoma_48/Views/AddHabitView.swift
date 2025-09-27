//
//  AddHabitView.swift
//  Habitally Dom
//
//  Created by Вячеслав on 9/27/25.
//

import SwiftUI

struct AddHabitView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var dataManager: DataManager
    
    @State private var name = ""
    @State private var description = ""
    @State private var selectedCategory = Habit.HabitCategory.health
    @State private var targetFrequency = 1
    @State private var frequencyType = Habit.FrequencyType.daily
    @State private var motivationalMessage = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.white.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        VStack(spacing: 8) {
                            Text("Create New Habit")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.black)
                            
                            Text("Build a positive habit that aligns with your goals")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top)
                        
                        VStack(spacing: 20) {
                            // Name field
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Habit Name")
                                    .font(.headline)
                                    .foregroundColor(.black)
                                
                                TextField("e.g., Drink 8 glasses of water", text: $name)
                                    .textFieldStyle(CustomTextFieldStyle())
                            }
                            
                            // Description field
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Description")
                                    .font(.headline)
                                    .foregroundColor(.black)
                                
                                TextField("Why is this habit important to you?", text: $description)
                                    .textFieldStyle(CustomTextFieldStyle())
                            }
                            
                            // Category selection
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Category")
                                    .font(.headline)
                                    .foregroundColor(.black)
                                
                                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                                    ForEach(Habit.HabitCategory.allCases, id: \.self) { category in
                                        CategoryCard(
                                            category: category,
                                            isSelected: selectedCategory == category
                                        ) {
                                            selectedCategory = category
                                        }
                                    }
                                }
                            }
                            
                            // Frequency settings
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Frequency")
                                    .font(.headline)
                                    .foregroundColor(.black)
                                
                                VStack(spacing: 16) {
                                    Picker("Frequency Type", selection: $frequencyType) {
                                        ForEach(Habit.FrequencyType.allCases, id: \.self) { type in
                                            Text(type.rawValue).tag(type)
                                        }
                                    }
                                    .pickerStyle(SegmentedPickerStyle())
                                    
                                    HStack {
                                        Text("Target:")
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                        
                                        Stepper(value: $targetFrequency, in: 1...20) {
                                            Text("\(targetFrequency) \(frequencyType.description)")
                                                .font(.subheadline)
                                                .fontWeight(.medium)
                                        }
                                    }
                                    .padding()
                                    .background(Color.gray.opacity(0.1))
                                    .cornerRadius(12)
                                }
                            }
                            
                            // Motivational message
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Motivational Message (Optional)")
                                    .font(.headline)
                                    .foregroundColor(.black)
                                
                                TextField("Custom message to celebrate completion", text: $motivationalMessage)
                                    .textFieldStyle(CustomTextFieldStyle())
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
                    createHabit()
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
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    private func createHabit() {
        let habit = Habit(
            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
            description: description.trimmingCharacters(in: .whitespacesAndNewlines),
            category: selectedCategory,
            targetFrequency: targetFrequency,
            frequencyType: frequencyType,
            motivationalMessage: motivationalMessage.trimmingCharacters(in: .whitespacesAndNewlines)
        )
        
        dataManager.addHabit(habit)
        presentationMode.wrappedValue.dismiss()
    }
}

struct CategoryCard: View {
    let category: Habit.HabitCategory
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

struct CustomTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
            .font(.body)
    }
}

#Preview {
    AddHabitView()
        .environmentObject(DataManager.shared)
}

//
//  EditHabitView.swift
//  Habitally Dom
//
//  Created by Вячеслав on 9/27/25.
//

import SwiftUI

struct EditHabitView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var dataManager: DataManager
    @Binding var habit: Habit
    
    @State private var name: String
    @State private var description: String
    @State private var selectedCategory: Habit.HabitCategory
    @State private var targetFrequency: Int
    @State private var frequencyType: Habit.FrequencyType
    @State private var motivationalMessage: String
    @State private var isActive: Bool
    
    init(habit: Binding<Habit>) {
        self._habit = habit
        self._name = State(initialValue: habit.wrappedValue.name)
        self._description = State(initialValue: habit.wrappedValue.description)
        self._selectedCategory = State(initialValue: habit.wrappedValue.category)
        self._targetFrequency = State(initialValue: habit.wrappedValue.targetFrequency)
        self._frequencyType = State(initialValue: habit.wrappedValue.frequencyType)
        self._motivationalMessage = State(initialValue: habit.wrappedValue.motivationalMessage)
        self._isActive = State(initialValue: habit.wrappedValue.isActive)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.white.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        VStack(spacing: 8) {
                            Text("Edit Habit")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.black)
                            
                            Text("Update your habit details")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top)
                        
                        VStack(spacing: 20) {
                            // Active toggle
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Active Habit")
                                        .font(.headline)
                                        .foregroundColor(.black)
                                    
                                    Text("Inactive habits won't appear in your daily list")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                                
                                Spacer()
                                
                                Toggle("", isOn: $isActive)
                                    .tint(Color(hex: "#2DCC72"))
                            }
                            .padding()
                            .background(Color.gray.opacity(0.05))
                            .cornerRadius(12)
                            
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
                                Text("Motivational Message")
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
                trailing: Button("Save") {
                    saveChanges()
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
    
    private func saveChanges() {
        habit.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        habit.description = description.trimmingCharacters(in: .whitespacesAndNewlines)
        habit.category = selectedCategory
        habit.targetFrequency = targetFrequency
        habit.frequencyType = frequencyType
        habit.motivationalMessage = motivationalMessage.trimmingCharacters(in: .whitespacesAndNewlines)
        habit.isActive = isActive
        
        dataManager.updateHabit(habit)
        presentationMode.wrappedValue.dismiss()
    }
}

#Preview {
    EditHabitView(habit: .constant(Habit(name: "Test", description: "Test habit", category: .health)))
        .environmentObject(DataManager.shared)
}

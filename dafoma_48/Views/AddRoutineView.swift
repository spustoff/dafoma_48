//
//  AddRoutineView.swift
//  Habitally Dom
//
//  Created by Вячеслав on 9/27/25.
//

import SwiftUI

struct AddRoutineView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var dataManager: DataManager
    
    @State private var name = ""
    @State private var description = ""
    @State private var selectedTimeOfDay = Routine.TimeOfDay.morning
    @State private var activities: [RoutineActivity] = []
    @State private var reminderEnabled = false
    @State private var reminderTime = Date()
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.white.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        VStack(spacing: 8) {
                            Text("Create New Routine")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.black)
                            
                            Text("Design a personalized routine to structure your day")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top)
                        
                        VStack(spacing: 20) {
                            // Name field
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Routine Name")
                                    .font(.headline)
                                    .foregroundColor(.black)
                                
                                TextField("e.g., Morning Energizer", text: $name)
                                    .textFieldStyle(CustomTextFieldStyle())
                            }
                            
                            // Description field
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Description")
                                    .font(.headline)
                                    .foregroundColor(.black)
                                
                                TextField("What does this routine help you achieve?", text: $description)
                                    .textFieldStyle(CustomTextFieldStyle())
                            }
                            
                            // Time of day selection
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Time of Day")
                                    .font(.headline)
                                    .foregroundColor(.black)
                                
                                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                                    ForEach(Routine.TimeOfDay.allCases, id: \.self) { timeOfDay in
                                        TimeOfDayCard(
                                            timeOfDay: timeOfDay,
                                            isSelected: selectedTimeOfDay == timeOfDay
                                        ) {
                                            selectedTimeOfDay = timeOfDay
                                            reminderTime = timeOfDay.suggestedTime
                                        }
                                    }
                                }
                            }
                            
                            // Reminder settings
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Text("Reminder")
                                        .font(.headline)
                                        .foregroundColor(.black)
                                    
                                    Spacer()
                                    
                                    Toggle("", isOn: $reminderEnabled)
                                        .tint(Color(hex: "#2DCC72"))
                                }
                                
                                if reminderEnabled {
                                    DatePicker("Reminder Time", selection: $reminderTime, displayedComponents: .hourAndMinute)
                                        .datePickerStyle(WheelDatePickerStyle())
                                        .padding()
                                        .background(Color.gray.opacity(0.1))
                                        .cornerRadius(12)
                                }
                            }
                            
                            // Activities
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Text("Activities")
                                        .font(.headline)
                                        .foregroundColor(.black)
                                    
                                    Spacer()
                                    
                                    Button(action: addActivity) {
                                        Image(systemName: "plus.circle.fill")
                                            .foregroundColor(Color(hex: "#2DCC72"))
                                    }
                                }
                                
                                if activities.isEmpty {
                                    VStack(spacing: 12) {
                                        Image(systemName: "list.bullet")
                                            .font(.title2)
                                            .foregroundColor(.gray)
                                        
                                        Text("No activities added yet")
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                        
                                        Button("Add First Activity") {
                                            addActivity()
                                        }
                                        .font(.subheadline)
                                        .foregroundColor(Color(hex: "#2DCC72"))
                                    }
                                    .padding(.vertical, 32)
                                } else {
                                    ForEach(activities.indices, id: \.self) { index in
                                        ActivityRow(
                                            activity: $activities[index],
                                            onDelete: { removeActivity(at: index) }
                                        )
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
                    createRoutine()
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
        !description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !activities.isEmpty
    }
    
    private func addActivity() {
        let newActivity = RoutineActivity(
            name: "",
            description: "",
            estimatedMinutes: 5,
            order: activities.count
        )
        activities.append(newActivity)
    }
    
    private func removeActivity(at index: Int) {
        activities.remove(at: index)
        // Update order for remaining activities
        for i in activities.indices {
            activities[i].order = i
        }
    }
    
    private func createRoutine() {
        var routine = Routine(
            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
            description: description.trimmingCharacters(in: .whitespacesAndNewlines),
            timeOfDay: selectedTimeOfDay
        )
        
        routine.activities = activities.filter { !$0.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
        routine.reminderEnabled = reminderEnabled
        routine.reminderTime = reminderEnabled ? reminderTime : nil
        
        dataManager.addRoutine(routine)
        presentationMode.wrappedValue.dismiss()
    }
}

struct TimeOfDayCard: View {
    let timeOfDay: Routine.TimeOfDay
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: timeOfDay.icon)
                .font(.title2)
                .foregroundColor(isSelected ? .white : Color(hex: timeOfDay.color))
            
            Text(timeOfDay.rawValue)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(isSelected ? .white : .black)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(isSelected ? Color(hex: timeOfDay.color) : Color.gray.opacity(0.1))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isSelected ? Color(hex: timeOfDay.color) : Color.clear, lineWidth: 2)
        )
        .onTapGesture {
            onTap()
        }
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}

struct ActivityRow: View {
    @Binding var activity: RoutineActivity
    let onDelete: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                TextField("Activity name", text: $activity.name)
                    .font(.subheadline)
                    .font(.system(size: 16, weight: .medium))
                
                Button(action: onDelete) {
                    Image(systemName: "minus.circle.fill")
                        .foregroundColor(.red)
                }
            }
            
            TextField("Description (optional)", text: $activity.description)
                .font(.caption)
                .foregroundColor(.gray)
            
            HStack {
                Text("Duration:")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Stepper(value: $activity.estimatedMinutes, in: 1...120) {
                    Text("\(activity.estimatedMinutes) minutes")
                        .font(.caption)
                        .font(.system(size: 16, weight: .medium))
                }
                
                Spacer()
                
                Toggle("Optional", isOn: $activity.isOptional)
                    .font(.caption)
                    .tint(Color(hex: "#2DCC72"))
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }
}

struct RoutineTemplatesView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var dataManager: DataManager
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    Text("Choose a Template")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                        .padding(.top)
                    
                    Text("Start with a pre-built routine and customize it to fit your needs")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    LazyVStack(spacing: 12) {
                        ForEach(Routine.templates, id: \.id) { template in
                            TemplateCard(routine: template) {
                                dataManager.addRoutine(template)
                                presentationMode.wrappedValue.dismiss()
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .navigationTitle("Templates")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: 
                Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
}

struct TemplateCard: View {
    let routine: Routine
    let onSelect: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: routine.timeOfDay.icon)
                    .font(.title3)
                    .foregroundColor(Color(hex: routine.timeOfDay.color))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(routine.name)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.black)
                    
                    Text(routine.description)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(routine.estimatedDuration) min")
                        .font(.caption)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.black)
                    
                    Text("\(routine.activities.count) activities")
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
            }
            
            // Activities preview
            VStack(alignment: .leading, spacing: 6) {
                ForEach(routine.activities.prefix(3), id: \.id) { activity in
                    HStack {
                        Circle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 4, height: 4)
                        
                        Text(activity.name)
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        Spacer()
                        
                        Text("\(activity.estimatedMinutes)m")
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }
                }
                
                if routine.activities.count > 3 {
                    Text("+ \(routine.activities.count - 3) more activities")
                        .font(.caption2)
                        .foregroundColor(.gray)
                        .padding(.leading, 8)
                }
            }
            
            Button(action: onSelect) {
                Text("Use This Template")
                    .font(.subheadline)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(Color(hex: routine.timeOfDay.color))
                    .cornerRadius(8)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

#Preview {
    AddRoutineView()
        .environmentObject(DataManager.shared)
}

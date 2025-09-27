//
//  ReflectionView.swift
//  Habitally Dom
//
//  Created by Вячеслав on 9/27/25.
//

import SwiftUI

struct ReflectionView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var dataManager: DataManager
    
    @State private var selectedPrompt = ReflectionPrompt.randomDailyPrompt()
    @State private var response = ""
    @State private var selectedMood: Reflection.Mood?
    @State private var gratitudeItems: [String] = ["", "", ""]
    @State private var insights = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.white.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        VStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(Color(hex: selectedPrompt.category.color))
                                    .frame(width: 80, height: 80)
                                
                                Image(systemName: selectedPrompt.category.icon)
                                    .font(.system(size: 35))
                                    .foregroundColor(.white)
                            }
                            
                            VStack(spacing: 8) {
                                Text("Daily Reflection")
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundColor(.black)
                                
                                Text("Take a moment to reflect on your day")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(.top)
                        
                        VStack(spacing: 20) {
                            // Reflection prompt
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Text("Today's Prompt")
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.black)
                                    
                                    Spacer()
                                    
                                    Button("Change") {
                                        selectedPrompt = ReflectionPrompt.randomDailyPrompt()
                                    }
                                    .font(.subheadline)
                                    .foregroundColor(Color(hex: selectedPrompt.category.color))
                                }
                                
                                Text(selectedPrompt.question)
                                    .font(.body)
                                    .foregroundColor(.black)
                                    .padding()
                                    .background(Color(hex: selectedPrompt.category.color).opacity(0.1))
                                    .cornerRadius(12)
                            }
                            
                            // Response
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Your Reflection")
                                    .font(.headline)
                                    .foregroundColor(.black)
                                
                                TextField("Share your thoughts...", text: $response)
                                    .textFieldStyle(CustomTextFieldStyle())
                            }
                            
                            // Mood selection
                            VStack(alignment: .leading, spacing: 12) {
                                Text("How are you feeling today?")
                                    .font(.headline)
                                    .foregroundColor(.black)
                                
                                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 12) {
                                    ForEach(Reflection.Mood.allCases, id: \.self) { mood in
                                        MoodCard(
                                            mood: mood,
                                            isSelected: selectedMood == mood
                                        ) {
                                            selectedMood = mood
                                        }
                                    }
                                }
                            }
                            
                            // Gratitude section
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Three Things I'm Grateful For")
                                    .font(.headline)
                                    .foregroundColor(.black)
                                
                                ForEach(gratitudeItems.indices, id: \.self) { index in
                                    HStack {
                                        Text("\(index + 1).")
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                            .frame(width: 20)
                                        
                                        TextField("Something you're grateful for", text: $gratitudeItems[index])
                                            .textFieldStyle(CustomTextFieldStyle())
                                    }
                                }
                            }
                            
                            // Insights
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Key Insights (Optional)")
                                    .font(.headline)
                                    .foregroundColor(.black)
                                
                                TextField("What did you learn about yourself today?", text: $insights)
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
                    saveReflection()
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
        !response.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    private func saveReflection() {
        let validGratitudeItems = gratitudeItems.compactMap { item in
            let trimmed = item.trimmingCharacters(in: .whitespacesAndNewlines)
            return trimmed.isEmpty ? nil : trimmed
        }
        
        let reflection = Reflection(
            prompt: selectedPrompt,
            response: response.trimmingCharacters(in: .whitespacesAndNewlines),
            mood: selectedMood,
            gratitude: validGratitudeItems,
            insights: insights.trimmingCharacters(in: .whitespacesAndNewlines)
        )
        
        dataManager.addReflection(reflection)
        presentationMode.wrappedValue.dismiss()
    }
}

struct MoodCard: View {
    let mood: Reflection.Mood
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        VStack(spacing: 8) {
            Text(mood.emoji)
                .font(.title)
            
            Text(mood.rawValue)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(isSelected ? .white : .black)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(isSelected ? Color(hex: mood.color) : Color.gray.opacity(0.1))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isSelected ? Color(hex: mood.color) : Color.clear, lineWidth: 2)
        )
        .onTapGesture {
            onTap()
        }
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}

struct ReflectionDetailView: View {
    @Environment(\.presentationMode) var presentationMode
    let reflection: Reflection
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header
                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(Color(hex: reflection.prompt.category.color))
                                .frame(width: 60, height: 60)
                            
                            Image(systemName: reflection.prompt.category.icon)
                                .font(.system(size: 25))
                                .foregroundColor(.white)
                        }
                        
                        VStack(spacing: 8) {
                            Text(formatDate(reflection.date))
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.black)
                            
                            if let mood = reflection.mood {
                                HStack {
                                    Text(mood.emoji)
                                    Text(mood.rawValue)
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                    }
                    
                    // Prompt and response
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Reflection Prompt")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.black)
                        
                        Text(reflection.prompt.question)
                            .font(.body)
                            .foregroundColor(.black)
                            .padding()
                            .background(Color(hex: reflection.prompt.category.color).opacity(0.1))
                            .cornerRadius(12)
                        
                        Text("Your Response")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.black)
                        
                        Text(reflection.response)
                            .font(.body)
                            .foregroundColor(.black)
                            .padding()
                            .background(Color.gray.opacity(0.05))
                            .cornerRadius(12)
                    }
                    
                    // Gratitude
                    if !reflection.gratitude.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Gratitude")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.black)
                            
                            ForEach(reflection.gratitude.indices, id: \.self) { index in
                                HStack {
                                    Text("\(index + 1).")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                        .frame(width: 20)
                                    
                                    Text(reflection.gratitude[index])
                                        .font(.body)
                                        .foregroundColor(.black)
                                    
                                    Spacer()
                                }
                                .padding()
                                .background(Color.gray.opacity(0.05))
                                .cornerRadius(12)
                            }
                        }
                    }
                    
                    // Insights
                    if !reflection.insights.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Key Insights")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.black)
                            
                            Text(reflection.insights)
                                .font(.body)
                                .foregroundColor(.black)
                                .padding()
                                .background(Color.gray.opacity(0.05))
                                .cornerRadius(12)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Reflection")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: 
                Button("Done") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        return formatter.string(from: date)
    }
}

#Preview {
    ReflectionView()
        .environmentObject(DataManager.shared)
}

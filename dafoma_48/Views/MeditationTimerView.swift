//
//  MeditationTimerView.swift
//  Habitally Dom
//
//  Created by Вячеслав on 9/27/25.
//

import SwiftUI

struct MeditationTimerView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var dataManager: DataManager
    
    @State private var selectedDuration = 5
    @State private var selectedType = MeditationSession.MeditationType.mindfulness
    @State private var timeRemaining = 300 // 5 minutes in seconds
    @State private var isActive = false
    @State private var isPaused = false
    @State private var showingCompletion = false
    @State private var notes = ""
    
    private let durations = [5, 10, 15, 20, 30]
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [Color(hex: "#4ECDC4"), Color(hex: "#96CEB4")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 40) {
                    if !isActive {
                        setupView
                    } else {
                        timerView
                    }
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(leading: 
                Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(.white)
            )
        }
        .onReceive(timer) { _ in
            if isActive && !isPaused && timeRemaining > 0 {
                timeRemaining -= 1
            } else if timeRemaining == 0 && isActive {
                completeSession()
            }
        }
        .sheet(isPresented: $showingCompletion) {
            MeditationCompletionView(
                duration: selectedDuration,
                type: selectedType,
                notes: $notes
            ) { session in
                dataManager.addMeditationSession(session)
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
    
    private var setupView: some View {
        VStack(spacing: 32) {
            // Header
            VStack(spacing: 16) {
                Image(systemName: "leaf.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.white)
                
                VStack(spacing: 8) {
                    Text("Meditation")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Find your inner peace")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                }
            }
            
            // Duration selection
            VStack(spacing: 16) {
                Text("Duration")
                    .font(.headline)
                    .foregroundColor(.white)
                
                HStack(spacing: 12) {
                    ForEach(durations, id: \.self) { duration in
                        Button(action: {
                            selectedDuration = duration
                            timeRemaining = duration * 60
                        }) {
                            Text("\(duration)m")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(selectedDuration == duration ? Color(hex: "#4ECDC4") : .white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(selectedDuration == duration ? .white : Color.white.opacity(0.2))
                                .cornerRadius(20)
                        }
                    }
                }
            }
            
            // Type selection
            VStack(spacing: 16) {
                Text("Meditation Type")
                    .font(.headline)
                    .foregroundColor(.white)
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                    ForEach(MeditationSession.MeditationType.allCases, id: \.self) { type in
                        MeditationTypeCard(
                            type: type,
                            isSelected: selectedType == type
                        ) {
                            selectedType = type
                        }
                    }
                }
            }
            
            Spacer()
            
            // Start button
            Button(action: startMeditation) {
                HStack {
                    Image(systemName: "play.fill")
                    Text("Begin Meditation")
                }
                .font(.headline)
                .foregroundColor(Color(hex: "#4ECDC4"))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(.white)
                .cornerRadius(25)
            }
        }
    }
    
    private var timerView: some View {
        VStack(spacing: 40) {
            // Timer display
            VStack(spacing: 16) {
                Text(selectedType.rawValue)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.3), lineWidth: 8)
                        .frame(width: 250, height: 250)
                    
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(Color.white, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                        .frame(width: 250, height: 250)
                        .rotationEffect(.degrees(-90))
                        .animation(.linear(duration: 1), value: progress)
                    
                    VStack(spacing: 8) {
                        Text(timeString)
                            .font(.system(size: 48, weight: .light, design: .monospaced))
                            .foregroundColor(.white)
                        
                        Text("remaining")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
            }
            
            // Meditation guidance
            VStack(spacing: 12) {
                Text(selectedType.description)
                    .font(.body)
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                if timeRemaining > Int(Double(selectedDuration * 60) * 0.8) {
                    Text("Take a deep breath and settle into your practice")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                } else if timeRemaining > Int(Double(selectedDuration * 60) * 0.2) {
                    Text("Stay present and focused on your breath")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                } else {
                    Text("Begin to bring your awareness back to the present")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                }
            }
            
            Spacer()
            
            // Control buttons
            HStack(spacing: 24) {
                Button(action: {
                    isActive = false
                    timeRemaining = selectedDuration * 60
                }) {
                    Image(systemName: "stop.fill")
                        .font(.title2)
                        .foregroundColor(.white)
                        .frame(width: 60, height: 60)
                        .background(Color.white.opacity(0.2))
                        .clipShape(Circle())
                }
                
                Button(action: {
                    isPaused.toggle()
                }) {
                    Image(systemName: isPaused ? "play.fill" : "pause.fill")
                        .font(.title)
                        .foregroundColor(Color(hex: "#4ECDC4"))
                        .frame(width: 80, height: 80)
                        .background(.white)
                        .clipShape(Circle())
                }
                
                Button(action: {
                    // Skip to end
                    timeRemaining = 0
                }) {
                    Image(systemName: "forward.end.fill")
                        .font(.title2)
                        .foregroundColor(.white)
                        .frame(width: 60, height: 60)
                        .background(Color.white.opacity(0.2))
                        .clipShape(Circle())
                }
            }
        }
    }
    
    private var progress: Double {
        let totalTime = Double(selectedDuration * 60)
        let elapsed = totalTime - Double(timeRemaining)
        return elapsed / totalTime
    }
    
    private var timeString: String {
        let minutes = timeRemaining / 60
        let seconds = timeRemaining % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    private func startMeditation() {
        isActive = true
        isPaused = false
        
        // Haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
    }
    
    private func completeSession() {
        isActive = false
        showingCompletion = true
        
        // Haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
        impactFeedback.impactOccurred()
    }
}

struct MeditationTypeCard: View {
    let type: MeditationSession.MeditationType
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: type.icon)
                .font(.title3)
                .foregroundColor(isSelected ? Color(hex: "#4ECDC4") : .white)
            
            Text(type.rawValue)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(isSelected ? Color(hex: "#4ECDC4") : .white)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(isSelected ? .white : Color.white.opacity(0.2))
        .cornerRadius(12)
        .onTapGesture {
            onTap()
        }
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}

struct MeditationCompletionView: View {
    @Environment(\.presentationMode) var presentationMode
    let duration: Int
    let type: MeditationSession.MeditationType
    @Binding var notes: String
    let onComplete: (MeditationSession) -> Void
    
    var body: some View {
        NavigationView {
            VStack(spacing: 32) {
                Spacer()
                
                // Completion animation/icon
                VStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(Color(hex: "#2DCC72"))
                            .frame(width: 100, height: 100)
                        
                        Image(systemName: "checkmark")
                            .font(.system(size: 40, weight: .bold))
                            .foregroundColor(.white)
                    }
                    
                    VStack(spacing: 8) {
                        Text("Well Done!")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                        
                        Text("You completed a \(duration)-minute \(type.rawValue.lowercased()) session")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                    }
                }
                
                // Notes section
                VStack(alignment: .leading, spacing: 12) {
                    Text("How was your session? (Optional)")
                        .font(.headline)
                        .foregroundColor(.black)
                    
                    TextField("Share your experience...", text: $notes)
                        .textFieldStyle(CustomTextFieldStyle())
                }
                .padding(.horizontal)
                
                Spacer()
                
                // Complete button
                Button(action: {
                    let session = MeditationSession(
                        duration: duration,
                        type: type,
                        notes: notes.isEmpty ? nil : notes
                    )
                    onComplete(session)
                }) {
                    Text("Complete Session")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color(hex: "#2DCC72"))
                        .cornerRadius(25)
                }
                .padding(.horizontal)
            }
            .navigationTitle("Session Complete")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: 
                Button("Skip") {
                    let session = MeditationSession(duration: duration, type: type)
                    onComplete(session)
                }
                .foregroundColor(.gray)
            )
        }
    }
}

struct RoutineDetailView: View {
    @Environment(\.presentationMode) var presentationMode
    let routine: Routine
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header
                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(Color(hex: routine.timeOfDay.color))
                                .frame(width: 80, height: 80)
                            
                            Image(systemName: routine.timeOfDay.icon)
                                .font(.system(size: 35))
                                .foregroundColor(.white)
                        }
                        
                        VStack(spacing: 8) {
                            Text(routine.name)
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.black)
                                .multilineTextAlignment(.center)
                            
                            Text(routine.description)
                                .font(.body)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                        }
                    }
                    
                    // Activities
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Activities")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.black)
                        
                        ForEach(routine.activities.sorted { $0.order < $1.order }, id: \.id) { activity in
                            HStack {
                                Text("\(activity.order + 1).")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(.gray)
                                    .frame(width: 30)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(activity.name)
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundColor(.black)
                                    
                                    if !activity.description.isEmpty {
                                        Text(activity.description)
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                }
                                
                                Spacer()
                                
                                VStack(alignment: .trailing, spacing: 2) {
                                    Text("\(activity.estimatedMinutes)m")
                                        .font(.caption)
                                        .fontWeight(.medium)
                                        .foregroundColor(.black)
                                    
                                    if activity.isOptional {
                                        Text("Optional")
                                            .font(.caption2)
                                            .foregroundColor(.gray)
                                    }
                                }
                            }
                            .padding()
                            .background(Color.gray.opacity(0.05))
                            .cornerRadius(12)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Routine")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    MeditationTimerView()
        .environmentObject(DataManager.shared)
}

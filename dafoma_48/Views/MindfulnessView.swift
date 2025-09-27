//
//  MindfulnessView.swift
//  Habitally Dom
//
//  Created by Вячеслав on 9/27/25.
//

import SwiftUI

struct MindfulnessView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var showingReflectionView = false
    @State private var showingMeditationTimer = false
    @State private var selectedReflection: Reflection?
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.white.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        headerView
                        
                        // Daily reflection card
                        dailyReflectionCard
                        
                        // Meditation section
                        meditationSection
                        
                        // Recent reflections
                        recentReflectionsSection
                        
                        Spacer(minLength: 100)
                    }
                    .padding()
                }
            }
            .navigationTitle("Mindfulness")
            .navigationBarTitleDisplayMode(.large)
        }
        .sheet(isPresented: $showingReflectionView) {
            ReflectionView()
        }
        .sheet(isPresented: $showingMeditationTimer) {
            MeditationTimerView()
        }
        .sheet(item: $selectedReflection) { reflection in
            ReflectionDetailView(reflection: reflection)
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 16) {
            HStack(spacing: 20) {
                StatCard(
                    title: "Reflections",
                    value: "\(dataManager.reflections.count)",
                    icon: "book.fill",
                    color: "#4ECDC4"
                )
                
                StatCard(
                    title: "Meditation",
                    value: "\(totalMeditationMinutes)",
                    icon: "leaf.fill",
                    color: "#96CEB4"
                )
                
                StatCard(
                    title: "This Week",
                    value: "\(reflectionsThisWeek)",
                    icon: "calendar",
                    color: "#DDA0DD"
                )
            }
        }
        .padding(.vertical)
        .background(Color.gray.opacity(0.05))
        .cornerRadius(16)
    }
    
    private var dailyReflectionCard: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Daily Reflection")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                    
                    Text(todayPrompt.question)
                        .font(.body)
                        .foregroundColor(.gray)
                        .lineLimit(3)
                }
                
                Spacer()
                
                Image(systemName: todayPrompt.category.icon)
                    .font(.title)
                    .foregroundColor(Color(hex: todayPrompt.category.color))
            }
            
            if hasReflectedToday {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(Color(hex: "#2DCC72"))
                    
                    Text("Completed today")
                        .font(.subheadline)
                        .foregroundColor(Color(hex: "#2DCC72"))
                    
                    Spacer()
                    
                    Button("View") {
                        if let todayReflection = dataManager.reflections.first(where: { Calendar.current.isDateInToday($0.date) }) {
                            selectedReflection = todayReflection
                        }
                    }
                    .font(.subheadline)
                    .foregroundColor(Color(hex: "#4ECDC4"))
                }
            } else {
                Button(action: { showingReflectionView = true }) {
                    HStack {
                        Image(systemName: "pencil")
                        Text("Start Reflecting")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color(hex: "#4ECDC4"))
                    .cornerRadius(12)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
    
    private var meditationSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Meditation")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                
                Spacer()
            }
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                MeditationCard(
                    title: "Quick Session",
                    subtitle: "5 minutes",
                    icon: "timer",
                    color: "#96CEB4",
                    duration: 5
                ) {
                    showingMeditationTimer = true
                }
                
                MeditationCard(
                    title: "Deep Focus",
                    subtitle: "15 minutes",
                    icon: "brain.head.profile",
                    color: "#4ECDC4",
                    duration: 15
                ) {
                    showingMeditationTimer = true
                }
                
                MeditationCard(
                    title: "Breathing",
                    subtitle: "10 minutes",
                    icon: "wind",
                    color: "#DDA0DD",
                    duration: 10
                ) {
                    showingMeditationTimer = true
                }
                
                MeditationCard(
                    title: "Body Scan",
                    subtitle: "20 minutes",
                    icon: "figure.mind.and.body",
                    color: "#FFEAA7",
                    duration: 20
                ) {
                    showingMeditationTimer = true
                }
            }
        }
    }
    
    private var recentReflectionsSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Recent Reflections")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                
                Spacer()
                
                if !dataManager.reflections.isEmpty {
                    Button("View All") {
                        // Could navigate to a full reflections list
                    }
                    .font(.subheadline)
                    .foregroundColor(Color(hex: "#4ECDC4"))
                }
            }
            
            if dataManager.reflections.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "book")
                        .font(.title2)
                        .foregroundColor(.gray)
                    
                    Text("No reflections yet")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    Text("Start your mindfulness journey with your first reflection")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }
                .padding(.vertical, 32)
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(dataManager.reflections.suffix(5).reversed(), id: \.id) { reflection in
                        ReflectionRow(reflection: reflection) {
                            selectedReflection = reflection
                        }
                    }
                }
            }
        }
    }
    
    private var todayPrompt: ReflectionPrompt {
        return ReflectionPrompt.randomDailyPrompt()
    }
    
    private var hasReflectedToday: Bool {
        return dataManager.reflections.contains { Calendar.current.isDateInToday($0.date) }
    }
    
    private var totalMeditationMinutes: String {
        let total = dataManager.meditationSessions.reduce(0) { $0 + $1.duration }
        if total >= 60 {
            return "\(total / 60)h \(total % 60)m"
        } else {
            return "\(total)m"
        }
    }
    
    private var reflectionsThisWeek: Int {
        let calendar = Calendar.current
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: Date())?.start ?? Date()
        
        return dataManager.reflections.filter { reflection in
            reflection.date >= startOfWeek
        }.count
    }
}

struct MeditationCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: String
    let duration: Int
    let onTap: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(Color(hex: color))
            
            VStack(spacing: 4) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.black)
                
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        .onTapGesture {
            onTap()
        }
    }
}

struct ReflectionRow: View {
    let reflection: Reflection
    let onTap: () -> Void
    
    var body: some View {
        HStack {
            Image(systemName: reflection.prompt.category.icon)
                .font(.title3)
                .foregroundColor(Color(hex: reflection.prompt.category.color))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(reflection.prompt.question)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.black)
                    .lineLimit(2)
                
                HStack {
                    Text(formatDate(reflection.date))
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    if let mood = reflection.mood {
                        Text("• \(mood.emoji) \(mood.rawValue)")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
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

#Preview {
    MindfulnessView()
        .environmentObject(DataManager.shared)
}

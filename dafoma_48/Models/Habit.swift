//
//  Habit.swift
//  Habitally Dom
//
//  Created by Вячеслав on 9/27/25.
//

import Foundation
import Combine

struct Habit: Identifiable, Codable {
    let id = UUID()
    var name: String
    var description: String
    var category: HabitCategory
    var targetFrequency: Int // times per day/week
    var frequencyType: FrequencyType
    var isActive: Bool
    var createdDate: Date
    var completions: [HabitCompletion]
    var motivationalMessage: String
    
    enum HabitCategory: String, CaseIterable, Codable {
        case health = "Health"
        case productivity = "Productivity"
        case mindfulness = "Mindfulness"
        case fitness = "Fitness"
        case learning = "Learning"
        case social = "Social"
        case creativity = "Creativity"
        
        var icon: String {
            switch self {
            case .health: return "heart.fill"
            case .productivity: return "checkmark.circle.fill"
            case .mindfulness: return "leaf.fill"
            case .fitness: return "figure.walk"
            case .learning: return "book.fill"
            case .social: return "person.2.fill"
            case .creativity: return "paintbrush.fill"
            }
        }
        
        var color: String {
            switch self {
            case .health: return "#FF6B6B"
            case .productivity: return "#2DCC72"
            case .mindfulness: return "#4ECDC4"
            case .fitness: return "#45B7D1"
            case .learning: return "#96CEB4"
            case .social: return "#FFEAA7"
            case .creativity: return "#DDA0DD"
            }
        }
    }
    
    enum FrequencyType: String, CaseIterable, Codable {
        case daily = "Daily"
        case weekly = "Weekly"
        
        var description: String {
            switch self {
            case .daily: return "times per day"
            case .weekly: return "times per week"
            }
        }
    }
    
    init(name: String, description: String, category: HabitCategory, targetFrequency: Int = 1, frequencyType: FrequencyType = .daily, motivationalMessage: String = "") {
        self.name = name
        self.description = description
        self.category = category
        self.targetFrequency = targetFrequency
        self.frequencyType = frequencyType
        self.isActive = true
        self.createdDate = Date()
        self.completions = []
        
        if motivationalMessage.isEmpty {
            self.motivationalMessage = Habit.generateDefaultMotivationalMessage()
        } else {
            self.motivationalMessage = motivationalMessage
        }
    }
    
    static func generateDefaultMotivationalMessage() -> String {
        let messages = [
            "Great job! You're building a better you! 🌟",
            "Consistency is key! Keep it up! 💪",
            "Another step towards your goals! 🎯",
            "You're creating positive change! ✨",
            "Progress over perfection! 🚀",
            "Your future self will thank you! 🙏",
            "Small steps, big results! 👏",
            "You're unstoppable! 🔥"
        ]
        return messages.randomElement() ?? "Well done!"
    }
    
    func completionsForDate(_ date: Date) -> [HabitCompletion] {
        let calendar = Calendar.current
        return completions.filter { calendar.isDate($0.completedDate, inSameDayAs: date) }
    }
    
    func isCompletedForDate(_ date: Date) -> Bool {
        let completionsToday = completionsForDate(date)
        return completionsToday.count >= targetFrequency
    }
    
    func progressForDate(_ date: Date) -> Double {
        let completionsToday = completionsForDate(date)
        return min(Double(completionsToday.count) / Double(targetFrequency), 1.0)
    }
    
    func currentStreak() -> Int {
        let calendar = Calendar.current
        var streak = 0
        var currentDate = Date()
        
        while true {
            if isCompletedForDate(currentDate) {
                streak += 1
                currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate) ?? currentDate
            } else {
                break
            }
        }
        
        return streak
    }
}

struct HabitCompletion: Identifiable, Codable {
    let id = UUID()
    let completedDate: Date
    let notes: String?
    
    init(notes: String? = nil) {
        self.completedDate = Date()
        self.notes = notes
    }
}

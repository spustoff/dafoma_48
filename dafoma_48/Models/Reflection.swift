//
//  Reflection.swift
//  Habitally Dom
//
//  Created by Вячеслав on 9/27/25.
//

import Foundation

struct Reflection: Identifiable, Codable {
    let id = UUID()
    var date: Date
    var prompt: ReflectionPrompt
    var response: String
    var mood: Mood?
    var gratitude: [String]
    var insights: String
    var createdDate: Date
    
    enum Mood: String, CaseIterable, Codable {
        case excellent = "Excellent"
        case good = "Good"
        case okay = "Okay"
        case challenging = "Challenging"
        case difficult = "Difficult"
        
        var emoji: String {
            switch self {
            case .excellent: return "😄"
            case .good: return "😊"
            case .okay: return "😐"
            case .challenging: return "😔"
            case .difficult: return "😞"
            }
        }
        
        var color: String {
            switch self {
            case .excellent: return "#2DCC72"
            case .good: return "#96CEB4"
            case .okay: return "#FFEAA7"
            case .challenging: return "#FDCB6E"
            case .difficult: return "#E17055"
            }
        }
        
        var description: String {
            switch self {
            case .excellent: return "Feeling amazing and energized"
            case .good: return "Positive and content"
            case .okay: return "Neutral, going through the motions"
            case .challenging: return "Facing some difficulties"
            case .difficult: return "Having a tough time"
            }
        }
    }
    
    init(prompt: ReflectionPrompt, response: String = "", mood: Mood? = nil, gratitude: [String] = [], insights: String = "") {
        self.date = Date()
        self.prompt = prompt
        self.response = response
        self.mood = mood
        self.gratitude = gratitude
        self.insights = insights
        self.createdDate = Date()
    }
}

struct ReflectionPrompt: Identifiable, Codable {
    let id = UUID()
    var question: String
    var category: PromptCategory
    var isDaily: Bool
    
    enum PromptCategory: String, CaseIterable, Codable {
        case gratitude = "Gratitude"
        case growth = "Growth"
        case relationships = "Relationships"
        case goals = "Goals"
        case mindfulness = "Mindfulness"
        case creativity = "Creativity"
        case wellness = "Wellness"
        
        var icon: String {
            switch self {
            case .gratitude: return "heart.fill"
            case .growth: return "arrow.up.circle.fill"
            case .relationships: return "person.2.fill"
            case .goals: return "target"
            case .mindfulness: return "leaf.fill"
            case .creativity: return "paintbrush.fill"
            case .wellness: return "figure.mind.and.body"
            }
        }
        
        var color: String {
            switch self {
            case .gratitude: return "#FF6B6B"
            case .growth: return "#2DCC72"
            case .relationships: return "#FFEAA7"
            case .goals: return "#45B7D1"
            case .mindfulness: return "#4ECDC4"
            case .creativity: return "#DDA0DD"
            case .wellness: return "#96CEB4"
            }
        }
    }
    
    init(question: String, category: PromptCategory, isDaily: Bool = false) {
        self.question = question
        self.category = category
        self.isDaily = isDaily
    }
}

// Predefined reflection prompts
extension ReflectionPrompt {
    static let dailyPrompts: [ReflectionPrompt] = [
        ReflectionPrompt(question: "What are three things you're grateful for today?", category: .gratitude, isDaily: true),
        ReflectionPrompt(question: "What was the highlight of your day?", category: .mindfulness, isDaily: true),
        ReflectionPrompt(question: "How did you grow or learn something new today?", category: .growth, isDaily: true),
        ReflectionPrompt(question: "What challenged you today, and how did you handle it?", category: .growth, isDaily: true),
        ReflectionPrompt(question: "How did you take care of your well-being today?", category: .wellness, isDaily: true)
    ]
    
    static let weeklyPrompts: [ReflectionPrompt] = [
        ReflectionPrompt(question: "What progress have you made toward your goals this week?", category: .goals),
        ReflectionPrompt(question: "How have your relationships evolved this week?", category: .relationships),
        ReflectionPrompt(question: "What creative ideas or solutions came to you this week?", category: .creativity),
        ReflectionPrompt(question: "What patterns do you notice in your thoughts and behaviors?", category: .mindfulness),
        ReflectionPrompt(question: "What would you like to improve or change next week?", category: .growth)
    ]
    
    static let monthlyPrompts: [ReflectionPrompt] = [
        ReflectionPrompt(question: "What are your biggest accomplishments this month?", category: .goals),
        ReflectionPrompt(question: "How have you changed or grown this month?", category: .growth),
        ReflectionPrompt(question: "What relationships have been most meaningful this month?", category: .relationships),
        ReflectionPrompt(question: "What habits have served you well, and which need adjustment?", category: .wellness),
        ReflectionPrompt(question: "What are you most excited about for next month?", category: .goals)
    ]
    
    static func randomDailyPrompt() -> ReflectionPrompt {
        return dailyPrompts.randomElement() ?? dailyPrompts[0]
    }
    
    static func randomWeeklyPrompt() -> ReflectionPrompt {
        return weeklyPrompts.randomElement() ?? weeklyPrompts[0]
    }
    
    static func randomMonthlyPrompt() -> ReflectionPrompt {
        return monthlyPrompts.randomElement() ?? monthlyPrompts[0]
    }
}

struct MeditationSession: Identifiable, Codable {
    let id = UUID()
    var duration: Int // in minutes
    var type: MeditationType
    var completedDate: Date
    var notes: String?
    
    enum MeditationType: String, CaseIterable, Codable {
        case mindfulness = "Mindfulness"
        case breathing = "Breathing"
        case bodyScanning = "Body Scanning"
        case loving_kindness = "Loving Kindness"
        case visualization = "Visualization"
        case walking = "Walking"
        
        var description: String {
            switch self {
            case .mindfulness: return "Focus on present moment awareness"
            case .breathing: return "Concentrate on breath patterns"
            case .bodyScanning: return "Progressive body awareness"
            case .loving_kindness: return "Cultivate compassion and love"
            case .visualization: return "Guided imagery and visualization"
            case .walking: return "Mindful movement meditation"
            }
        }
        
        var icon: String {
            switch self {
            case .mindfulness: return "brain.head.profile"
            case .breathing: return "wind"
            case .bodyScanning: return "figure.mind.and.body"
            case .loving_kindness: return "heart.fill"
            case .visualization: return "eye.fill"
            case .walking: return "figure.walk"
            }
        }
    }
    
    init(duration: Int, type: MeditationType, notes: String? = nil) {
        self.duration = duration
        self.type = type
        self.completedDate = Date()
        self.notes = notes
    }
}

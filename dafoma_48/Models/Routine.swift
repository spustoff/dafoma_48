//
//  Routine.swift
//  Habitally Dom
//
//  Created by Вячеслав on 9/27/25.
//

import Foundation

struct Routine: Identifiable, Codable {
    let id = UUID()
    var name: String
    var description: String
    var timeOfDay: TimeOfDay
    var isActive: Bool
    var createdDate: Date
    var activities: [RoutineActivity]
    var reminderEnabled: Bool
    var reminderTime: Date?
    var completions: [RoutineCompletion]
    
    enum TimeOfDay: String, CaseIterable, Codable {
        case morning = "Morning"
        case afternoon = "Afternoon"
        case evening = "Evening"
        case night = "Night"
        
        var icon: String {
            switch self {
            case .morning: return "sunrise.fill"
            case .afternoon: return "sun.max.fill"
            case .evening: return "sunset.fill"
            case .night: return "moon.fill"
            }
        }
        
        var color: String {
            switch self {
            case .morning: return "#FFD93D"
            case .afternoon: return "#FF6B35"
            case .evening: return "#6BCF7F"
            case .night: return "#4D4DFF"
            }
        }
        
        var suggestedTime: Date {
            let calendar = Calendar.current
            let now = Date()
            var components = calendar.dateComponents([.year, .month, .day], from: now)
            
            switch self {
            case .morning:
                components.hour = 7
                components.minute = 0
            case .afternoon:
                components.hour = 14
                components.minute = 0
            case .evening:
                components.hour = 18
                components.minute = 0
            case .night:
                components.hour = 21
                components.minute = 0
            }
            
            return calendar.date(from: components) ?? now
        }
    }
    
    init(name: String, description: String, timeOfDay: TimeOfDay) {
        self.name = name
        self.description = description
        self.timeOfDay = timeOfDay
        self.isActive = true
        self.createdDate = Date()
        self.activities = []
        self.reminderEnabled = false
        self.reminderTime = timeOfDay.suggestedTime
        self.completions = []
    }
    
    var estimatedDuration: Int {
        return activities.reduce(0) { $0 + $1.estimatedMinutes }
    }
    
    func completionsForDate(_ date: Date) -> [RoutineCompletion] {
        let calendar = Calendar.current
        return completions.filter { calendar.isDate($0.completedDate, inSameDayAs: date) }
    }
    
    func isCompletedForDate(_ date: Date) -> Bool {
        return !completionsForDate(date).isEmpty
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
    
    mutating func addActivity(_ activity: RoutineActivity) {
        activities.append(activity)
    }
    
    mutating func removeActivity(withId id: UUID) {
        activities.removeAll { $0.id == id }
    }
    
    mutating func completeRoutine(notes: String? = nil) {
        let completion = RoutineCompletion(notes: notes)
        completions.append(completion)
    }
}

struct RoutineActivity: Identifiable, Codable {
    let id = UUID()
    var name: String
    var description: String
    var estimatedMinutes: Int
    var isOptional: Bool
    var order: Int
    
    init(name: String, description: String, estimatedMinutes: Int, isOptional: Bool = false, order: Int = 0) {
        self.name = name
        self.description = description
        self.estimatedMinutes = estimatedMinutes
        self.isOptional = isOptional
        self.order = order
    }
}

struct RoutineCompletion: Identifiable, Codable {
    let id = UUID()
    let completedDate: Date
    let notes: String?
    let duration: Int? // actual duration in minutes
    
    init(notes: String? = nil, duration: Int? = nil) {
        self.completedDate = Date()
        self.notes = notes
        self.duration = duration
    }
}

// Predefined routine templates
extension Routine {
    static let templates: [Routine] = [
        Routine.morningRoutineTemplate,
        Routine.eveningRoutineTemplate,
        Routine.workoutRoutineTemplate,
        Routine.studyRoutineTemplate
    ]
    
    static var morningRoutineTemplate: Routine {
        var routine = Routine(name: "Energizing Morning", description: "Start your day with purpose and energy", timeOfDay: .morning)
        routine.activities = [
            RoutineActivity(name: "Drink Water", description: "Hydrate after sleep", estimatedMinutes: 2, order: 1),
            RoutineActivity(name: "Stretch", description: "Light stretching or yoga", estimatedMinutes: 10, order: 2),
            RoutineActivity(name: "Meditation", description: "5-minute mindfulness practice", estimatedMinutes: 5, order: 3),
            RoutineActivity(name: "Review Goals", description: "Check daily priorities", estimatedMinutes: 5, order: 4),
            RoutineActivity(name: "Healthy Breakfast", description: "Nutritious meal to fuel your day", estimatedMinutes: 15, order: 5)
        ]
        return routine
    }
    
    static var eveningRoutineTemplate: Routine {
        var routine = Routine(name: "Peaceful Evening", description: "Wind down and prepare for rest", timeOfDay: .evening)
        routine.activities = [
            RoutineActivity(name: "Reflect on Day", description: "Journal about today's experiences", estimatedMinutes: 10, order: 1),
            RoutineActivity(name: "Plan Tomorrow", description: "Set priorities for tomorrow", estimatedMinutes: 5, order: 2),
            RoutineActivity(name: "Digital Detox", description: "Put away devices", estimatedMinutes: 1, order: 3),
            RoutineActivity(name: "Reading", description: "Read something inspiring", estimatedMinutes: 20, isOptional: true, order: 4),
            RoutineActivity(name: "Prepare for Sleep", description: "Get ready for restful sleep", estimatedMinutes: 15, order: 5)
        ]
        return routine
    }
    
    static var workoutRoutineTemplate: Routine {
        var routine = Routine(name: "Fitness Focus", description: "Stay active and healthy", timeOfDay: .afternoon)
        routine.activities = [
            RoutineActivity(name: "Warm-up", description: "Light cardio and stretching", estimatedMinutes: 10, order: 1),
            RoutineActivity(name: "Main Workout", description: "Strength or cardio training", estimatedMinutes: 30, order: 2),
            RoutineActivity(name: "Cool Down", description: "Stretching and recovery", estimatedMinutes: 10, order: 3),
            RoutineActivity(name: "Hydrate", description: "Drink water and refuel", estimatedMinutes: 5, order: 4)
        ]
        return routine
    }
    
    static var studyRoutineTemplate: Routine {
        var routine = Routine(name: "Learning Session", description: "Focused time for growth and learning", timeOfDay: .afternoon)
        routine.activities = [
            RoutineActivity(name: "Review Previous Material", description: "Quick recap of last session", estimatedMinutes: 10, order: 1),
            RoutineActivity(name: "Active Learning", description: "Engage with new content", estimatedMinutes: 25, order: 2),
            RoutineActivity(name: "Break", description: "Short rest to recharge", estimatedMinutes: 5, order: 3),
            RoutineActivity(name: "Practice/Apply", description: "Apply what you've learned", estimatedMinutes: 20, order: 4),
            RoutineActivity(name: "Summarize", description: "Note key takeaways", estimatedMinutes: 10, order: 5)
        ]
        return routine
    }
}

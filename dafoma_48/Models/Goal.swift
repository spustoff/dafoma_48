//
//  Goal.swift
//  Habitally Dom
//
//  Created by Вячеслав on 9/27/25.
//

import Foundation

struct Goal: Identifiable, Codable {
    let id = UUID()
    var title: String
    var description: String
    var category: GoalCategory
    var targetDate: Date
    var isCompleted: Bool
    var createdDate: Date
    var milestones: [Milestone]
    var relatedHabits: [UUID] // References to Habit IDs
    var priority: Priority
    
    enum GoalCategory: String, CaseIterable, Codable {
        case health = "Health"
        case career = "Career"
        case personal = "Personal"
        case financial = "Financial"
        case relationships = "Relationships"
        case education = "Education"
        case lifestyle = "Lifestyle"
        
        var icon: String {
            switch self {
            case .health: return "heart.fill"
            case .career: return "briefcase.fill"
            case .personal: return "person.fill"
            case .financial: return "dollarsign.circle.fill"
            case .relationships: return "heart.2.fill"
            case .education: return "graduationcap.fill"
            case .lifestyle: return "house.fill"
            }
        }
        
        var color: String {
            switch self {
            case .health: return "#FF6B6B"
            case .career: return "#2DCC72"
            case .personal: return "#4ECDC4"
            case .financial: return "#45B7D1"
            case .relationships: return "#FFEAA7"
            case .education: return "#96CEB4"
            case .lifestyle: return "#DDA0DD"
            }
        }
    }
    
    enum Priority: String, CaseIterable, Codable {
        case low = "Low"
        case medium = "Medium"
        case high = "High"
        case critical = "Critical"
        
        var color: String {
            switch self {
            case .low: return "#95A5A6"
            case .medium: return "#F39C12"
            case .high: return "#E74C3C"
            case .critical: return "#8E44AD"
            }
        }
        
        var sortOrder: Int {
            switch self {
            case .critical: return 0
            case .high: return 1
            case .medium: return 2
            case .low: return 3
            }
        }
    }
    
    init(title: String, description: String, category: GoalCategory, targetDate: Date, priority: Priority = .medium) {
        self.title = title
        self.description = description
        self.category = category
        self.targetDate = targetDate
        self.isCompleted = false
        self.createdDate = Date()
        self.milestones = []
        self.relatedHabits = []
        self.priority = priority
    }
    
    var isShortTerm: Bool {
        let calendar = Calendar.current
        let monthsFromNow = calendar.dateInterval(of: .month, for: Date())?.end ?? Date()
        return targetDate <= calendar.date(byAdding: .month, value: 3, to: Date()) ?? Date()
    }
    
    var isLongTerm: Bool {
        return !isShortTerm
    }
    
    var progress: Double {
        guard !milestones.isEmpty else { return isCompleted ? 1.0 : 0.0 }
        let completedMilestones = milestones.filter { $0.isCompleted }.count
        return Double(completedMilestones) / Double(milestones.count)
    }
    
    var daysRemaining: Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: Date(), to: targetDate)
        return max(components.day ?? 0, 0)
    }
    
    var isOverdue: Bool {
        return !isCompleted && targetDate < Date()
    }
    
    mutating func addMilestone(_ milestone: Milestone) {
        milestones.append(milestone)
        milestones.sort { $0.targetDate < $1.targetDate }
    }
    
    mutating func completeMilestone(withId id: UUID) {
        if let index = milestones.firstIndex(where: { $0.id == id }) {
            milestones[index].isCompleted = true
            milestones[index].completedDate = Date()
        }
    }
    
    var nextMilestone: Milestone? {
        return milestones.first { !$0.isCompleted }
    }
}

struct Milestone: Identifiable, Codable {
    let id = UUID()
    var title: String
    var description: String
    var targetDate: Date
    var isCompleted: Bool
    var completedDate: Date?
    var createdDate: Date
    
    init(title: String, description: String, targetDate: Date) {
        self.title = title
        self.description = description
        self.targetDate = targetDate
        self.isCompleted = false
        self.completedDate = nil
        self.createdDate = Date()
    }
    
    var isOverdue: Bool {
        return !isCompleted && targetDate < Date()
    }
    
    var daysRemaining: Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: Date(), to: targetDate)
        return max(components.day ?? 0, 0)
    }
}

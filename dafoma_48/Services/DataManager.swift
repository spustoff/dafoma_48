//
//  DataManager.swift
//  Habitally Dom
//
//  Created by Вячеслав on 9/27/25.
//

import Foundation
import Combine

class DataManager: ObservableObject {
    static let shared = DataManager()
    
    @Published var habits: [Habit] = []
    @Published var goals: [Goal] = []
    @Published var routines: [Routine] = []
    @Published var reflections: [Reflection] = []
    @Published var meditationSessions: [MeditationSession] = []
    
    private let userDefaults = UserDefaults.standard
    private var cancellables = Set<AnyCancellable>()
    
    // Keys for UserDefaults
    private enum Keys {
        static let habits = "habits"
        static let goals = "goals"
        static let routines = "routines"
        static let reflections = "reflections"
        static let meditationSessions = "meditationSessions"
        static let hasCompletedOnboarding = "hasCompletedOnboarding"
    }
    
    private init() {
        loadData()
        setupAutoSave()
    }
    
    // MARK: - Data Loading
    private func loadData() {
        loadHabits()
        loadGoals()
        loadRoutines()
        loadReflections()
        loadMeditationSessions()
    }
    
    private func loadHabits() {
        if let data = userDefaults.data(forKey: Keys.habits),
           let decodedHabits = try? JSONDecoder().decode([Habit].self, from: data) {
            habits = decodedHabits
        } else {
            habits = createSampleHabits()
            saveHabits()
        }
    }
    
    private func loadGoals() {
        if let data = userDefaults.data(forKey: Keys.goals),
           let decodedGoals = try? JSONDecoder().decode([Goal].self, from: data) {
            goals = decodedGoals
        } else {
            goals = createSampleGoals()
            saveGoals()
        }
    }
    
    private func loadRoutines() {
        if let data = userDefaults.data(forKey: Keys.routines),
           let decodedRoutines = try? JSONDecoder().decode([Routine].self, from: data) {
            routines = decodedRoutines
        } else {
            routines = []
        }
    }
    
    private func loadReflections() {
        if let data = userDefaults.data(forKey: Keys.reflections),
           let decodedReflections = try? JSONDecoder().decode([Reflection].self, from: data) {
            reflections = decodedReflections
        } else {
            reflections = []
        }
    }
    
    private func loadMeditationSessions() {
        if let data = userDefaults.data(forKey: Keys.meditationSessions),
           let decodedSessions = try? JSONDecoder().decode([MeditationSession].self, from: data) {
            meditationSessions = decodedSessions
        } else {
            meditationSessions = []
        }
    }
    
    // MARK: - Auto Save Setup
    private func setupAutoSave() {
        $habits
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                self?.saveHabits()
            }
            .store(in: &cancellables)
        
        $goals
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                self?.saveGoals()
            }
            .store(in: &cancellables)
        
        $routines
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                self?.saveRoutines()
            }
            .store(in: &cancellables)
        
        $reflections
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                self?.saveReflections()
            }
            .store(in: &cancellables)
        
        $meditationSessions
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                self?.saveMeditationSessions()
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Data Saving
    private func saveHabits() {
        if let encoded = try? JSONEncoder().encode(habits) {
            userDefaults.set(encoded, forKey: Keys.habits)
        }
    }
    
    private func saveGoals() {
        if let encoded = try? JSONEncoder().encode(goals) {
            userDefaults.set(encoded, forKey: Keys.goals)
        }
    }
    
    private func saveRoutines() {
        if let encoded = try? JSONEncoder().encode(routines) {
            userDefaults.set(encoded, forKey: Keys.routines)
        }
    }
    
    private func saveReflections() {
        if let encoded = try? JSONEncoder().encode(reflections) {
            userDefaults.set(encoded, forKey: Keys.reflections)
        }
    }
    
    private func saveMeditationSessions() {
        if let encoded = try? JSONEncoder().encode(meditationSessions) {
            userDefaults.set(encoded, forKey: Keys.meditationSessions)
        }
    }
    
    // MARK: - Habit Management
    func addHabit(_ habit: Habit) {
        habits.append(habit)
    }
    
    func updateHabit(_ habit: Habit) {
        if let index = habits.firstIndex(where: { $0.id == habit.id }) {
            habits[index] = habit
        }
    }
    
    func deleteHabit(withId id: UUID) {
        habits.removeAll { $0.id == id }
    }
    
    func completeHabit(withId id: UUID, notes: String? = nil) {
        if let index = habits.firstIndex(where: { $0.id == id }) {
            let completion = HabitCompletion(notes: notes)
            habits[index].completions.append(completion)
        }
    }
    
    // MARK: - Goal Management
    func addGoal(_ goal: Goal) {
        goals.append(goal)
    }
    
    func updateGoal(_ goal: Goal) {
        if let index = goals.firstIndex(where: { $0.id == goal.id }) {
            goals[index] = goal
        }
    }
    
    func deleteGoal(withId id: UUID) {
        goals.removeAll { $0.id == id }
    }
    
    func completeGoal(withId id: UUID) {
        if let index = goals.firstIndex(where: { $0.id == id }) {
            goals[index].isCompleted = true
        }
    }
    
    // MARK: - Routine Management
    func addRoutine(_ routine: Routine) {
        routines.append(routine)
    }
    
    func updateRoutine(_ routine: Routine) {
        if let index = routines.firstIndex(where: { $0.id == routine.id }) {
            routines[index] = routine
        }
    }
    
    func deleteRoutine(withId id: UUID) {
        routines.removeAll { $0.id == id }
    }
    
    func completeRoutine(withId id: UUID, notes: String? = nil) {
        if let index = routines.firstIndex(where: { $0.id == id }) {
            routines[index].completeRoutine(notes: notes)
        }
    }
    
    // MARK: - Reflection Management
    func addReflection(_ reflection: Reflection) {
        reflections.append(reflection)
    }
    
    func updateReflection(_ reflection: Reflection) {
        if let index = reflections.firstIndex(where: { $0.id == reflection.id }) {
            reflections[index] = reflection
        }
    }
    
    func deleteReflection(withId id: UUID) {
        reflections.removeAll { $0.id == id }
    }
    
    // MARK: - Meditation Management
    func addMeditationSession(_ session: MeditationSession) {
        meditationSessions.append(session)
    }
    
    func deleteMeditationSession(withId id: UUID) {
        meditationSessions.removeAll { $0.id == id }
    }
    
    // MARK: - Onboarding
    var hasCompletedOnboarding: Bool {
        get {
            userDefaults.bool(forKey: Keys.hasCompletedOnboarding)
        }
        set {
            userDefaults.set(newValue, forKey: Keys.hasCompletedOnboarding)
        }
    }
    
    // MARK: - Account Deletion / Reset
    func resetAllData() {
        habits = []
        goals = []
        routines = []
        reflections = []
        meditationSessions = []
        hasCompletedOnboarding = false
        
        // Clear UserDefaults
        userDefaults.removeObject(forKey: Keys.habits)
        userDefaults.removeObject(forKey: Keys.goals)
        userDefaults.removeObject(forKey: Keys.routines)
        userDefaults.removeObject(forKey: Keys.reflections)
        userDefaults.removeObject(forKey: Keys.meditationSessions)
        userDefaults.removeObject(forKey: Keys.hasCompletedOnboarding)
    }
    
    // MARK: - Sample Data Creation
    private func createSampleHabits() -> [Habit] {
        return [
            Habit(name: "Drink Water", description: "Stay hydrated throughout the day", category: .health, targetFrequency: 8, motivationalMessage: "Hydration is the foundation of health! 💧"),
            Habit(name: "Morning Meditation", description: "Start the day with mindfulness", category: .mindfulness, targetFrequency: 1, motivationalMessage: "Peace begins with a single breath 🧘‍♀️"),
            Habit(name: "Read for 30 minutes", description: "Expand knowledge and imagination", category: .learning, targetFrequency: 1, motivationalMessage: "Every page is a step toward wisdom 📚"),
            Habit(name: "Exercise", description: "Keep your body strong and healthy", category: .fitness, targetFrequency: 1, motivationalMessage: "Your body is your temple - treat it well! 💪")
        ]
    }
    
    private func createSampleGoals() -> [Goal] {
        let calendar = Calendar.current
        let nextMonth = calendar.date(byAdding: .month, value: 1, to: Date()) ?? Date()
        let nextYear = calendar.date(byAdding: .year, value: 1, to: Date()) ?? Date()
        
        var goal1 = Goal(title: "Build a Consistent Morning Routine", description: "Establish a healthy morning routine that sets a positive tone for each day", category: .lifestyle, targetDate: nextMonth, priority: .high)
        goal1.addMilestone(Milestone(title: "Define routine activities", description: "List 5 key morning activities", targetDate: calendar.date(byAdding: .day, value: 7, to: Date()) ?? Date()))
        goal1.addMilestone(Milestone(title: "Practice for 1 week", description: "Follow routine for 7 consecutive days", targetDate: calendar.date(byAdding: .day, value: 14, to: Date()) ?? Date()))
        
        var goal2 = Goal(title: "Learn a New Skill", description: "Master a new skill that contributes to personal or professional growth", category: .education, targetDate: nextYear, priority: .medium)
        goal2.addMilestone(Milestone(title: "Choose skill to learn", description: "Research and select a skill to focus on", targetDate: calendar.date(byAdding: .day, value: 3, to: Date()) ?? Date()))
        goal2.addMilestone(Milestone(title: "Complete first course", description: "Finish an introductory course or tutorial", targetDate: calendar.date(byAdding: .month, value: 3, to: Date()) ?? Date()))
        
        return [goal1, goal2]
    }
    
    // MARK: - Analytics and Insights
    func getHabitCompletionRate(for habit: Habit, days: Int = 30) -> Double {
        let calendar = Calendar.current
        let startDate = calendar.date(byAdding: .day, value: -days, to: Date()) ?? Date()
        let completedDays = (0..<days).compactMap { dayOffset in
            calendar.date(byAdding: .day, value: -dayOffset, to: Date())
        }.filter { date in
            habit.isCompletedForDate(date)
        }.count
        
        return Double(completedDays) / Double(days)
    }
    
    func getTotalMeditationMinutes(days: Int = 30) -> Int {
        let calendar = Calendar.current
        let startDate = calendar.date(byAdding: .day, value: -days, to: Date()) ?? Date()
        
        return meditationSessions
            .filter { $0.completedDate >= startDate }
            .reduce(0) { $0 + $1.duration }
    }
    
    func getActiveGoalsCount() -> Int {
        return goals.filter { !$0.isCompleted }.count
    }
    
    func getCompletedGoalsCount() -> Int {
        return goals.filter { $0.isCompleted }.count
    }
}

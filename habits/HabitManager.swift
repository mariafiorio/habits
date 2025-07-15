//
//  HabitManager.swift
//  habits
//
//  Created by Maria on 11/07/25.
//


import SwiftUI
import Foundation

// MARK: - Data Manager
class HabitManager: ObservableObject {
    @Published var habits: [Habit] = []
    @Published var userProfile: UserProfile = UserProfile()
    
    init() {
        loadHabits()
        loadProfile()
        if habits.isEmpty {
            createSampleHabits()
        }
    }
    
    private func createSampleHabits() {
        habits = [
            Habit(name: "Exercitar", icon: "figure.run", color: .blue, streak: 5, completedDates: Set(getLastDays(5)), target: 5, isAllDays: true),
            Habit(name: "Meditar", icon: "leaf.fill", color: .green, streak: 3, completedDates: Set(getLastDays(3)), target: 7, isAllDays: true),
            Habit(name: "Ler", icon: "book.fill", color: .orange, streak: 7, completedDates: Set(getLastDays(7)), target: 6, selectedDays: [2, 3, 4, 5, 6, 7], isAllDays: false),
            Habit(name: "Água", icon: "drop.fill", color: .cyan, streak: 10, completedDates: Set(getLastDays(10)), target: 7, isAllDays: true)
        ]
        saveHabits()
    }
    
    private func getLastDays(_ count: Int) -> [String] {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return (0..<count).compactMap { offset in
            Calendar.current.date(byAdding: .day, value: -offset, to: Date())
        }.map { formatter.string(from: $0) }
    }
    
    func toggleHabit(_ habit: Habit) {
        guard let index = habits.firstIndex(where: { $0.id == habit.id }) else { return }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let today = formatter.string(from: Date())
        
        if habits[index].completedDates.contains(today) {
            habits[index].completedDates.remove(today)
            habits[index].streak = max(0, habits[index].streak - 1)
        } else {
            habits[index].completedDates.insert(today)
            habits[index].streak += 1
        }
        
        saveHabits()
    }
    
    func addHabit(name: String, icon: String, color: Color, target: Int, selectedDays: Set<Int> = [], reminders: [HabitReminder] = [], isAllDays: Bool = true) {
        let habit = Habit(name: name, icon: icon, color: color, target: target, selectedDays: selectedDays, reminders: reminders, isAllDays: isAllDays)
        habits.append(habit)
        saveHabits()
        
        // Schedule reminders if any
        scheduleReminders(for: habit)
    }
    
    private func scheduleReminders(for habit: Habit) {
        NotificationManager.shared.scheduleReminders(for: habit)
    }
    
    func deleteHabit(_ habit: Habit) {
        // Remove notifications before deleting
        NotificationManager.shared.removeReminders(for: habit)
        habits.removeAll { $0.id == habit.id }
        saveHabits()
    }
    
    func updateProfile(_ profile: UserProfile) {
        userProfile = profile
        saveProfile()
    }
    
    func saveHabits() {
        if let encoded = try? JSONEncoder().encode(habits) {
            UserDefaults.standard.set(encoded, forKey: "habits")
        }
    }
    
    // MARK: - Statistics
    var totalHabitsCompleted: Int {
        habits.reduce(0) { $0 + $1.totalCompletions }
    }
    
    var averageCompletionRate: Double {
        guard !habits.isEmpty else { return 0 }
        let totalRate = habits.reduce(0.0) { $0 + $1.completionRate }
        return totalRate / Double(habits.count)
    }
    
    var longestStreak: Int {
        habits.map { $0.streak }.max() ?? 0
    }
    
    var completedTodayCount: Int {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let today = formatter.string(from: Date())
        return habits.filter { $0.completedDates.contains(today) }.count
    }
    
    // MARK: - Persistence
    private func loadHabits() {
        if let data = UserDefaults.standard.data(forKey: "habits"),
           let decoded = try? JSONDecoder().decode([Habit].self, from: data) {
            habits = decoded
        }
    }
    
    private func saveProfile() {
        if let encoded = try? JSONEncoder().encode(userProfile) {
            UserDefaults.standard.set(encoded, forKey: "userProfile")
        }
    }
    
    private func loadProfile() {
        if let data = UserDefaults.standard.data(forKey: "userProfile"),
           let decoded = try? JSONDecoder().decode(UserProfile.self, from: data) {
            userProfile = decoded
        }
    }
}

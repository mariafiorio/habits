//
//  Habit.swift
//  habits
//
//  Created by Maria on 11/07/25.
//


import SwiftUI
import Foundation

// MARK: - Reminder Model
struct HabitReminder: Identifiable, Codable {
    let id = UUID()
    var time: Date
    var isEnabled: Bool
    var message: String
    
    init(time: Date = Date(), isEnabled: Bool = false, message: String = "") {
        self.time = time
        self.isEnabled = isEnabled
        self.message = message
    }
}

// MARK: - Habit Model
struct Habit: Identifiable, Codable {
    let id = UUID()
    var name: String
    var icon: String
    var color: Color
    var streak: Int
    var completedDates: Set<String>
    var target: Int // days per week
    var createdDate: Date
    var selectedDays: Set<Int> // 1 = Sunday, 2 = Monday, ..., 7 = Saturday
    var reminders: [HabitReminder]
    var isAllDays: Bool // true if habit should be done every day
    
    init(name: String, icon: String, color: Color, streak: Int = 0, completedDates: Set<String> = [], target: Int, createdDate: Date = Date(), selectedDays: Set<Int> = [], reminders: [HabitReminder] = [], isAllDays: Bool = true) {
        self.name = name
        self.icon = icon
        self.color = color
        self.streak = streak
        self.completedDates = completedDates
        self.target = target
        self.createdDate = createdDate
        self.selectedDays = selectedDays
        self.reminders = reminders
        self.isAllDays = isAllDays
    }
    
    var completionRate: Double {
        let calendar = Calendar.current
        let today = Date()
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        let daysThisWeek = (0..<7).compactMap { offset in
            calendar.date(byAdding: .day, value: -offset, to: today)
        }.map { formatter.string(from: $0) }
        
        let completedThisWeek = daysThisWeek.filter { completedDates.contains($0) }.count
        return target > 0 ? min(Double(completedThisWeek) / Double(target), 1.0) : 0.0
    }
    
    var totalCompletions: Int {
        return completedDates.count
    }
    
    var daysActive: Int {
        let calendar = Calendar.current
        let daysSinceCreation = calendar.dateComponents([.day], from: createdDate, to: Date()).day ?? 0
        return max(1, daysSinceCreation + 1)
    }
    
    // Helper method to get day names
    func getDayNames() -> [String] {
        let dayNames = ["Domingo", "Segunda", "Terça", "Quarta", "Quinta", "Sexta", "Sábado"]
        return selectedDays.sorted().map { dayNames[$0 - 1] }
    }
    
    // Helper method to check if habit should be done today
    func shouldBeDoneToday() -> Bool {
        if isAllDays { return true }
        
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: Date())
        return selectedDays.contains(weekday)
    }
}

// MARK: - User Profile Model
struct UserProfile: Codable {
    var name: String
    var joinDate: Date
    var dailyGoal: Int
    var weeklyGoal: Int
    var notifications: Bool
    var theme: String
    
    init() {
        self.name = "Usuário"
        self.joinDate = Date()
        self.dailyGoal = 3
        self.weeklyGoal = 21
        self.notifications = true
        self.theme = "system"
    }
}

// MARK: - Color Extension for Codable
extension Color: Codable {
    enum CodingKeys: String, CodingKey {
        case red, green, blue, alpha
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let r = try container.decode(Double.self, forKey: .red)
        let g = try container.decode(Double.self, forKey: .green)
        let b = try container.decode(Double.self, forKey: .blue)
        let a = try container.decode(Double.self, forKey: .alpha)
        self.init(red: r, green: g, blue: b, opacity: a)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        let components = UIColor(self).cgColor.components ?? [0, 0, 0, 1]
        try container.encode(Double(components[0]), forKey: .red)
        try container.encode(Double(components[1]), forKey: .green)
        try container.encode(Double(components[2]), forKey: .blue)
        try container.encode(Double(components[3]), forKey: .alpha)
    }
}
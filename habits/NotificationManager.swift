//
//  NotificationManager.swift
//  habits
//
//  Created by Maria on 11/07/25.
//

import Foundation
import UserNotifications

class NotificationManager: ObservableObject {
    static let shared = NotificationManager()
    
    private init() {
        requestAuthorization()
    }
    
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                print("Notification permission granted")
            } else if let error = error {
                print("Notification permission error: \(error)")
            }
        }
    }
    
    func scheduleReminders(for habit: Habit) {
        // Remove existing notifications for this habit
        removeReminders(for: habit)
        
        // Schedule new reminders
        for reminder in habit.reminders where reminder.isEnabled {
            scheduleReminder(reminder, for: habit)
        }
    }
    
    private func scheduleReminder(_ reminder: HabitReminder, for habit: Habit) {
        let content = UNMutableNotificationContent()
        content.title = "Lembrete de Hábito"
        content.body = reminder.message.isEmpty ? "Hora de \(habit.name)!" : reminder.message
        content.sound = .default
        content.badge = 1
        
        // Create date components for the reminder time
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: reminder.time)
        
        // Create trigger
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        
        // Create request
        let request = UNNotificationRequest(
            identifier: "habit-\(habit.id.uuidString)-\(reminder.id.uuidString)",
            content: content,
            trigger: trigger
        )
        
        // Schedule notification
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            } else {
                print("Notification scheduled for habit: \(habit.name)")
            }
        }
    }
    
    func removeReminders(for habit: Habit) {
        let identifiers = habit.reminders.map { "habit-\(habit.id.uuidString)-\($0.id.uuidString)" }
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
    }
    
    func removeAllReminders() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
} 
//
//  HabitDetailView.swift
//  habits
//
//  Created by Maria on 11/07/25.
//

import SwiftUI

struct HabitDetailView: View {
    @ObservedObject var habitManager: HabitManager
    let habit: Habit
    @Environment(\.presentationMode) var presentationMode
    @State private var showingEditSheet = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 16) {
                    Text(habit.icon)
                        .font(.system(size: 60))
                    
                    Text(habit.name)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    HStack(spacing: 20) {
                        VStack {
                            Text("\(habit.streak)")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(habit.color)
                            Text("Sequência")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        VStack {
                            Text("\(habit.totalCompletions)")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(habit.color)
                            Text("Total")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        VStack {
                            Text("\(habit.daysActive)")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(habit.color)
                            Text("Dias Ativo")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(16)
                .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                
                // Schedule Info
                VStack(alignment: .leading, spacing: 12) {
                    Text("Agenda")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    VStack(spacing: 12) {
                        HStack {
                            Image(systemName: "calendar")
                                .foregroundColor(habit.color)
                            Text(habit.isAllDays ? "Todos os dias" : "Dias selecionados")
                            Spacer()
                        }
                        
                        if !habit.isAllDays {
                            HStack {
                                Text("Dias:")
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text(habit.getDayNames().joined(separator: ", "))
                                    .font(.subheadline)
                            }
                        }
                        
                        HStack {
                            Image(systemName: "target")
                                .foregroundColor(habit.color)
                            Text("Meta: \(habit.target) dias por semana")
                            Spacer()
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                }
                
                // Reminders
                if !habit.reminders.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Lembretes")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        VStack(spacing: 8) {
                            ForEach(habit.reminders) { reminder in
                                HStack {
                                    Image(systemName: "bell.fill")
                                        .foregroundColor(reminder.isEnabled ? habit.color : .gray)
                                    
                                    VStack(alignment: .leading) {
                                        Text(reminder.message.isEmpty ? "Lembrete" : reminder.message)
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                        
                                        Text(formatTime(reminder.time))
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    if reminder.isEnabled {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.green)
                                            .font(.caption)
                                    }
                                }
                                .padding()
                                .background(Color(.systemBackground))
                                .cornerRadius(8)
                            }
                        }
                    }
                }
                
                // Recent Activity
                VStack(alignment: .leading, spacing: 12) {
                    Text("Atividade Recente")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                        ForEach(getLast7Days(), id: \.self) { date in
                            VStack {
                                Text(formatDay(date))
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                
                                Circle()
                                    .fill(habit.completedDates.contains(formatDate(date)) ? habit.color : Color.gray.opacity(0.2))
                                    .frame(width: 24, height: 24)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                    )
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                }
            }
            .padding()
        }
        .navigationTitle("Detalhes")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Editar") {
                    showingEditSheet = true
                }
            }
        }
        .sheet(isPresented: $showingEditSheet) {
            EditHabitSheet(habitManager: habitManager, habit: habit)
        }
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func getLast7Days() -> [Date] {
        let calendar = Calendar.current
        return (0..<7).compactMap { offset in
            calendar.date(byAdding: .day, value: -offset, to: Date())
        }.reversed()
    }
    
    private func formatDay(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        formatter.locale = Locale(identifier: "pt_BR")
        return formatter.string(from: date).prefix(1).uppercased()
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}

// MARK: - Edit Habit Sheet
struct EditHabitSheet: View {
    @ObservedObject var habitManager: HabitManager
    let habit: Habit
    @Environment(\.presentationMode) var presentationMode
    
    @State private var name: String
    @State private var selectedIcon: String
    @State private var selectedColor: Color
    @State private var target: Int
    @State private var isAllDays: Bool
    @State private var selectedDays: Set<Int>
    @State private var reminders: [HabitReminder]
    @State private var showingReminderSheet = false
    
    private let emojis = ["⭐", "❤️", "📚", "🏃‍♀️", "🍃", "💧", "🌙", "☀️", "🧠", "💪", "💊", "🛏️", "🏠", "🚗", "✈️", "🎮", "🎵", "📷", "✏️", "✂️", "🏋️‍♀️", "🧘‍♀️", "🚴‍♀️", "🏊‍♀️", "🎯", "🎨", "📝", "🔋", "🌱", "🍎", "💡", "🎪", "🎭", "🎨", "📖", "🎓", "🏆", "🌟", "💎", "🎁", "🎈"]
    private let colors: [Color] = [.blue, .green, .orange, .red, .purple, .cyan, .pink, .yellow, .indigo, .mint, .brown, .gray, .teal, .purple, .orange]
    private let dayNames = ["Dom", "Seg", "Ter", "Qua", "Qui", "Sex", "Sáb"]
    
    init(habitManager: HabitManager, habit: Habit) {
        self.habitManager = habitManager
        self.habit = habit
        self._name = State(initialValue: habit.name)
        self._selectedIcon = State(initialValue: habit.icon)
        self._selectedColor = State(initialValue: habit.color)
        self._target = State(initialValue: habit.target)
        self._isAllDays = State(initialValue: habit.isAllDays)
        self._selectedDays = State(initialValue: habit.selectedDays)
        self._reminders = State(initialValue: habit.reminders)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Informações do Hábito") {
                    TextField("Nome do hábito", text: $name)
                    
                    HStack {
                        Text("Meta semanal:")
                        Spacer()
                        Stepper("\(target) dias", value: $target, in: 1...7)
                    }
                }
                
                Section("Dias da Semana") {
                    VStack(alignment: .leading, spacing: 12) {
                        Toggle("Todos os dias", isOn: $isAllDays)
                        
                        if !isAllDays {
                            Text("Selecione os dias:")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                                ForEach(1...7, id: \.self) { day in
                                    Button(action: {
                                        if selectedDays.contains(day) {
                                            selectedDays.remove(day)
                                        } else {
                                            selectedDays.insert(day)
                                        }
                                    }) {
                                        Text(dayNames[day - 1])
                                            .font(.caption)
                                            .fontWeight(.medium)
                                            .foregroundColor(selectedDays.contains(day) ? .white : .primary)
                                            .frame(width: 40, height: 40)
                                            .background(selectedDays.contains(day) ? selectedColor : Color.gray.opacity(0.2))
                                            .cornerRadius(20)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 20)
                                                    .stroke(selectedDays.contains(day) ? selectedColor : Color.clear, lineWidth: 2)
                                            )
                                    }
                                }
                            }
                            
                            if !selectedDays.isEmpty {
                                Text("Dias selecionados: \(selectedDays.sorted().map { dayNames[$0 - 1] }.joined(separator: ", "))")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .padding(.top, 4)
                            }
                        }
                    }
                }
                
                Section("Lembretes") {
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(reminders.indices, id: \.self) { index in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(reminders[index].message.isEmpty ? "Lembrete \(index + 1)" : reminders[index].message)
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                    
                                    Text(formatTime(reminders[index].time))
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                Toggle("", isOn: $reminders[index].isEnabled)
                            }
                            .padding(.vertical, 4)
                        }
                        
                        Button(action: {
                            showingReminderSheet = true
                        }) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                Text("Adicionar Lembrete")
                            }
                            .foregroundColor(selectedColor)
                        }
                    }
                }
                
                Section("Emoji") {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Emoji personalizado:")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        TextField("Digite um emoji (ex: 🎯)", text: $selectedIcon)
                            .font(.title2)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .onChange(of: selectedIcon) { newValue in
                                // Limita a apenas um emoji
                                if newValue.count > 2 {
                                    selectedIcon = String(newValue.prefix(2))
                                }
                            }
                        
                        Text("Ou escolha um emoji:")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding(.top, 8)
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 8), spacing: 12) {
                            ForEach(emojis, id: \.self) { emoji in
                                Button(action: {
                                    selectedIcon = emoji
                                }) {
                                    Text(emoji)
                                        .font(.title)
                                        .frame(width: 44, height: 44)
                                        .background(selectedIcon == emoji ? selectedColor.opacity(0.2) : Color.gray.opacity(0.1))
                                        .cornerRadius(8)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(selectedIcon == emoji ? selectedColor : Color.clear, lineWidth: 2)
                                        )
                                }
                            }
                        }
                    }
                }
                
                Section("Cor") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 16) {
                        ForEach(Array(colors.enumerated()), id: \.offset) { index, color in
                            Button(action: {
                                selectedColor = color
                            }) {
                                Circle()
                                    .fill(color)
                                    .frame(width: 44, height: 44)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.primary, lineWidth: selectedColor == color ? 3 : 0)
                                    )
                                    .overlay(
                                        Circle()
                                            .stroke(Color.white, lineWidth: selectedColor == color ? 1 : 0)
                                    )
                            }
                        }
                    }
                }
            }
            .navigationTitle("Editar Hábito")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Salvar") {
                        if !name.isEmpty && (isAllDays || !selectedDays.isEmpty) && !selectedIcon.isEmpty {
                            updateHabit()
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                    .disabled(name.isEmpty || selectedIcon.isEmpty || (!isAllDays && selectedDays.isEmpty))
                }
            }
            .sheet(isPresented: $showingReminderSheet) {
                AddReminderSheet(reminders: $reminders, selectedColor: selectedColor)
            }
        }
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func updateHabit() {
        // Find and update the habit
        if let index = habitManager.habits.firstIndex(where: { $0.id == habit.id }) {
            habitManager.habits[index].name = name
            habitManager.habits[index].icon = selectedIcon
            habitManager.habits[index].color = selectedColor
            habitManager.habits[index].target = target
            habitManager.habits[index].isAllDays = isAllDays
            habitManager.habits[index].selectedDays = isAllDays ? [] : selectedDays
            habitManager.habits[index].reminders = reminders.filter { $0.isEnabled }
            
            // Update notifications
            NotificationManager.shared.scheduleReminders(for: habitManager.habits[index])
            
            habitManager.saveHabits()
        }
    }
} 
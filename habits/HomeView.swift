//
//  HomeView.swift
//  habits
//
//  Created by Maria on 11/07/25.
//


import SwiftUI

// MARK: - Home View
struct HomeView: View {
    @ObservedObject var habitManager: HabitManager
    @State private var showingAddHabit = false
    @State private var showingCelebration = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    // Daily summary card
                    DailySummaryCard(habitManager: habitManager)
                    
                    if habitManager.habits.isEmpty {
                        // Empty state
                        VStack(spacing: 20) {
                            Text("🎯")
                                .font(.system(size: 60))
                            
                            Text("Nenhum hábito criado")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                            
                            Text("Comece criando seu primeiro hábito para começar sua jornada de desenvolvimento pessoal!")
                                .font(.body)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                            
                            Button(action: {
                                showingAddHabit = true
                            }) {
                                HStack {
                                    Image(systemName: "plus.circle.fill")
                                    Text("Criar Primeiro Hábito")
                                }
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.horizontal, 24)
                                .padding(.vertical, 12)
                                .background(Color.blue)
                                .cornerRadius(25)
                            }
                        }
                        .padding(40)
                        .background(Color(.systemBackground))
                        .cornerRadius(16)
                        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                    } else {
                        // Habits list
                        LazyVStack(spacing: 16) {
                            ForEach(habitManager.habits) { habit in
                                HabitCard(habit: habit, habitManager: habitManager)
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Meus Hábitos")
            .background(Color(.systemGroupedBackground))
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddHabit = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                }
            }
            .sheet(isPresented: $showingAddHabit) {
                AddHabitSheet(habitManager: habitManager)
            }
            .fullScreenCover(isPresented: $showingCelebration) {
                CelebrationView(isShowing: $showingCelebration)
            }
            .onReceive(NotificationCenter.default.publisher(for: .dailyGoalsCompleted)) { _ in
                showingCelebration = true
            }
        }
    }
}

// MARK: - Daily Summary Card
struct DailySummaryCard: View {
    @ObservedObject var habitManager: HabitManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Hoje")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    if habitManager.habits.isEmpty {
                        Text("Nenhum hábito configurado")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    } else {
                        Text("\(habitManager.completedTodayCount) de \(habitManager.habits.filter { $0.shouldBeDoneToday() }.count) concluídos")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                // Circular progress
                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.2), lineWidth: 6)
                        .frame(width: 60, height: 60)
                    
                    if !habitManager.habits.isEmpty {
                        let todayHabits = habitManager.habits.filter { $0.shouldBeDoneToday() }
                        let progress = todayHabits.isEmpty ? 0 : Double(habitManager.completedTodayCount) / Double(todayHabits.count)
                        
                        Circle()
                            .trim(from: 0, to: progress)
                            .stroke(Color.blue, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                            .frame(width: 60, height: 60)
                            .rotationEffect(.degrees(-90))
                            .animation(.easeInOut, value: habitManager.completedTodayCount)
                        
                        Text("\(Int(progress * 100))%")
                            .font(.caption)
                            .fontWeight(.semibold)
                    } else {
                        Text("0%")
                            .font(.caption)
                            .fontWeight(.semibold)
                    }
                }
            }
            
            // Quick stats
            if !habitManager.habits.isEmpty {
                HStack(spacing: 20) {
                    StatItem(title: "Sequência", value: "\(habitManager.longestStreak)", color: .green)
                    StatItem(title: "Total", value: "\(habitManager.totalHabitsCompleted)", color: .blue)
                    StatItem(title: "Média", value: "\(Int(habitManager.averageCompletionRate * 100))%", color: .orange)
                }
            } else {
                HStack(spacing: 20) {
                    StatItem(title: "Hábitos", value: "0", color: .gray)
                    StatItem(title: "Concluídos", value: "0", color: .gray)
                    StatItem(title: "Média", value: "0%", color: .gray)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

// MARK: - Stat Item
struct StatItem: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Habit Card
struct HabitCard: View {
    let habit: Habit
    @ObservedObject var habitManager: HabitManager
    
    private var isCompletedToday: Bool {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let today = formatter.string(from: Date())
        return habit.completedDates.contains(today)
    }
    
    private var shouldShowToday: Bool {
        return habit.shouldBeDoneToday()
    }
    
    var body: some View {
        NavigationLink(destination: HabitDetailView(habitManager: habitManager, habit: habit)) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(habit.icon)
                        .font(.title2)
                        .frame(width: 32, height: 32)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(habit.name)
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        HStack(spacing: 8) {
                            Text("\(habit.streak) dias seguidos")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            if !habit.isAllDays {
                                Text("•")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                Text(habit.getDayNames().joined(separator: ", "))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .lineLimit(1)
                            }
                        }
                    }
                    
                    Spacer()
                    
                    if shouldShowToday {
                        Button(action: {
                            withAnimation(.spring()) {
                                habitManager.toggleHabit(habit)
                            }
                        }) {
                            Image(systemName: isCompletedToday ? "checkmark.circle.fill" : "circle")
                                .font(.title2)
                                .foregroundColor(isCompletedToday ? habit.color : .gray)
                        }
                        .buttonStyle(PlainButtonStyle())
                    } else {
                        Text("Hoje não")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                    }
                }
                
                // Progress bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 8)
                            .cornerRadius(4)
                        
                        Rectangle()
                            .fill(habit.color)
                            .frame(width: geometry.size.width * habit.completionRate, height: 8)
                            .cornerRadius(4)
                            .animation(.easeInOut, value: habit.completionRate)
                    }
                }
                .frame(height: 8)
                
                HStack {
                    Text("\(Int(habit.completionRate * 100))% desta semana")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("\(habit.target) dias/semana")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // Show reminders if any
                if !habit.reminders.isEmpty {
                    HStack {
                        Image(systemName: "bell.fill")
                            .font(.caption)
                            .foregroundColor(habit.color)
                        
                        Text("\(habit.reminders.count) lembrete\(habit.reminders.count > 1 ? "s" : "")")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                    }
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
            .opacity(shouldShowToday ? 1.0 : 0.6)
        }
        .buttonStyle(PlainButtonStyle())
        .contextMenu {
            Button(role: .destructive) {
                habitManager.deleteHabit(habit)
            } label: {
                Label("Excluir", systemImage: "trash")
            }
        }
    }
}
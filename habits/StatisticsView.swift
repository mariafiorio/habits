import SwiftUI
import Charts

// MARK: - Statistics View
struct StatisticsView: View {
    @ObservedObject var habitManager: HabitManager
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Overall completion chart
                    OverallStatsCard(habits: habitManager.habits)
                    
                    // Weekly progress chart
                    WeeklyProgressChart(habits: habitManager.habits)
                    
                    // Individual habit stats
                    ForEach(habitManager.habits) { habit in
                        HabitStatsCard(habit: habit)
                    }
                }
                .padding()
            }
            .navigationTitle("Estatísticas")
            .background(Color(.systemGroupedBackground))
        }
    }
}

// MARK: - Overall Stats Card
struct OverallStatsCard: View {
    let habits: [Habit]
    
    private var totalHabits: Int { habits.count }
    private var completedToday: Int {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let today = formatter.string(from: Date())
        return habits.filter { $0.completedDates.contains(today) }.count
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Resumo Geral")
                .font(.headline)
                .foregroundColor(.primary)
            
            HStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("\(completedToday)/\(totalHabits)")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("Concluídos hoje")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Pie chart representation
                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.2), lineWidth: 8)
                        .frame(width: 80, height: 80)
                    
                    Circle()
                        .trim(from: 0, to: totalHabits > 0 ? Double(completedToday) / Double(totalHabits) : 0)
                        .stroke(Color.blue, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                        .frame(width: 80, height: 80)
                        .rotationEffect(.degrees(-90))
                        .animation(.easeInOut, value: completedToday)
                    
                    Text("\(totalHabits > 0 ? Int(Double(completedToday) / Double(totalHabits) * 100) : 0)%")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

// MARK: - Weekly Progress Chart
struct WeeklyProgressChart: View {
    let habits: [Habit]
    
    private var weeklyData: [(String, Int)] {
        let calendar = Calendar.current
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        
        return (0..<7).map { offset in
            let date = calendar.date(byAdding: .day, value: -offset, to: Date())!
            let dayFormatter = DateFormatter()
            dayFormatter.dateFormat = "yyyy-MM-dd"
            let dateString = dayFormatter.string(from: date)
            
            let completedCount = habits.filter { $0.completedDates.contains(dateString) }.count
            return (formatter.string(from: date), completedCount)
        }.reversed()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Progresso Semanal")
                .font(.headline)
                .foregroundColor(.primary)
            
            if #available(iOS 16.0, *) {
                Chart {
                    ForEach(Array(weeklyData.enumerated()), id: \.offset) { index, data in
                        BarMark(
                            x: .value("Day", data.0),
                            y: .value("Completed", data.1)
                        )
                        .foregroundStyle(Color.blue)
                        .cornerRadius(4)
                    }
                }
                .frame(height: 200)
            } else {
                // Fallback for older iOS versions
                HStack(alignment: .bottom, spacing: 8) {
                    ForEach(Array(weeklyData.enumerated()), id: \.offset) { index, data in
                        VStack(spacing: 4) {
                            Rectangle()
                                .fill(Color.blue)
                                .frame(width: 32, height: max(4, CGFloat(data.1 * 20)))
                                .cornerRadius(2)
                            
                            Text(data.0)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .frame(height: 200)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

// MARK: - Habit Stats Card
struct HabitStatsCard: View {
    let habit: Habit
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: habit.icon)
                    .font(.title2)
                    .foregroundColor(habit.color)
                
                Text(habit.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
            }
            
            HStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(habit.streak)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(habit.color)
                    
                    Text("Sequência")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(Int(habit.completionRate * 100))%")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(habit.color)
                    
                    Text("Esta semana")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(habit.totalCompletions)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(habit.color)
                    
                    Text("Total")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

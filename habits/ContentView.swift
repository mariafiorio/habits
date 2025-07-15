import SwiftUI

// MARK: - Main Content View
struct ContentView: View {
    @StateObject private var habitManager = HabitManager()
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView(habitManager: habitManager)
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Início")
                }
                .tag(0)
            
            StatisticsView(habitManager: habitManager)
                .tabItem {
                    Image(systemName: "chart.bar.fill")
                    Text("Estatísticas")
                }
                .tag(1)
            
            ProfileView(habitManager: habitManager)
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Perfil")
                }
                .tag(2)
        }
        .accentColor(.primary)
    }
}

// MARK: - Add Habit Sheet
struct AddHabitSheet: View {
    @ObservedObject var habitManager: HabitManager
    @Environment(\.presentationMode) var presentationMode
    
    @State private var name = ""
    @State private var selectedIcon = "⭐"
    @State private var selectedColor = Color.blue
    @State private var target = 7
    @State private var isAllDays = true
    @State private var selectedDays: Set<Int> = []
    @State private var reminders: [HabitReminder] = []
    @State private var showingReminderSheet = false
    
    private let emojis = ["⭐", "❤️", "📚", "🏃‍♀️", "🍃", "💧", "🌙", "☀️", "🧠", "💪", "💊", "🛏️", "🏠", "🚗", "✈️", "🎮", "🎵", "📷", "✏️", "✂️", "🏋️‍♀️", "🧘‍♀️", "🚴‍♀️", "🏊‍♀️", "🎯", "🎨", "📝", "🔋", "🌱", "🍎", "💡", "🎪", "🎭", "🎨", "📖", "🎓", "🏆", "🌟", "💎", "🎁", "🎈"]
    private let colors: [Color] = [.blue, .green, .orange, .red, .purple, .cyan, .pink, .yellow, .indigo, .mint, .brown, .gray, .teal, .purple, .orange]
    private let dayNames = ["Dom", "Seg", "Ter", "Qua", "Qui", "Sex", "Sáb"]
    
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
            .navigationTitle("Novo Hábito")
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
                            let finalSelectedDays = isAllDays ? [] : selectedDays
                            habitManager.addHabit(
                                name: name,
                                icon: selectedIcon,
                                color: selectedColor,
                                target: target,
                                selectedDays: finalSelectedDays,
                                reminders: reminders.filter { $0.isEnabled },
                                isAllDays: isAllDays
                            )
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
}

// MARK: - Add Reminder Sheet
struct AddReminderSheet: View {
    @Binding var reminders: [HabitReminder]
    let selectedColor: Color
    @Environment(\.presentationMode) var presentationMode
    
    @State private var time = Date()
    @State private var message = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section("Horário") {
                    DatePicker("Horário", selection: $time, displayedComponents: .hourAndMinute)
                }
                
                Section("Mensagem (opcional)") {
                    TextField("Ex: Hora de exercitar!", text: $message)
                }
            }
            .navigationTitle("Novo Lembrete")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Adicionar") {
                        let reminder = HabitReminder(time: time, isEnabled: true, message: message)
                        reminders.append(reminder)
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Preview
#Preview {
    ContentView()
}

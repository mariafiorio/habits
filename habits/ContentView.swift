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
    @State private var selectedIcon = "star.fill"
    @State private var selectedColor = Color.blue
    @State private var target = 7
    
    private let icons = ["star.fill", "heart.fill", "book.fill", "figure.run", "leaf.fill", "drop.fill", "moon.fill", "sun.max.fill", "brain.head.profile", "dumbbell.fill"]
    private let colors: [Color] = [.blue, .green, .orange, .red, .purple, .cyan, .pink, .yellow, .indigo, .mint]
    
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
                
                Section("Ícone") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 16) {
                        ForEach(icons, id: \.self) { icon in
                            Button(action: {
                                selectedIcon = icon
                            }) {
                                Image(systemName: icon)
                                    .font(.title2)
                                    .foregroundColor(selectedIcon == icon ? selectedColor : .gray)
                                    .frame(width: 44, height: 44)
                                    .background(selectedIcon == icon ? selectedColor.opacity(0.1) : Color.clear)
                                    .cornerRadius(8)
                            }
                        }
                    }
                }
                
                Section("Cor") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 16) {
                        ForEach(colors, id: \.self) { color in
                            Button(action: {
                                selectedColor = color
                            }) {
                                Circle()
                                    .fill(color)
                                    .frame(width: 44, height: 44)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.primary, lineWidth: selectedColor == color ? 2 : 0)
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
                        if !name.isEmpty {
                            habitManager.addHabit(name: name, icon: selectedIcon, color: selectedColor, target: target)
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
}

// MARK: - Preview
#Preview {
    ContentView()
}

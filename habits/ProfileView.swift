import SwiftUI

// MARK: - Profile View
struct ProfileView: View {
    @ObservedObject var habitManager: HabitManager
    @State private var showingEditProfile = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Profile header
                    ProfileHeaderCard(profile: habitManager.userProfile)
                    
                    // Achievement cards
                    AchievementsSection(habitManager: habitManager)
                    
                    // Settings section
                    SettingsSection(habitManager: habitManager, showingEditProfile: $showingEditProfile)
                }
                .padding()
            }
            .navigationTitle("Perfil")
            .background(Color(.systemGroupedBackground))
            .sheet(isPresented: $showingEditProfile) {
                EditProfileSheet(habitManager: habitManager)
            }
        }
    }
}

// MARK: - Profile Header Card
struct ProfileHeaderCard: View {
    let profile: UserProfile
    
    var body: some View {
        VStack(spacing: 16) {
            // Avatar
            ZStack {
                Circle()
                    .fill(LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 80, height: 80)
                
                Text(String(profile.name.prefix(1)).uppercased())
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            
            VStack(spacing: 4) {
                Text(profile.name)
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("Membro desde \(profile.joinDate, formatter: dateFormatter)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }
}

// MARK: - Achievements Section
struct AchievementsSection: View {
    @ObservedObject var habitManager: HabitManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Conquistas")
                .font(.headline)
                .padding(.horizontal)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                AchievementCard(
                    title: "Total de Hábitos",
                    value: "\(habitManager.totalHabitsCompleted)",
                    icon: "star.fill",
                    color: .yellow
                )
                
                AchievementCard(
                    title: "Maior Sequência",
                    value: "\(habitManager.longestStreak)",
                    icon: "flame.fill",
                    color: .orange
                )
                
                AchievementCard(
                    title: "Hábitos Ativos",
                    value: "\(habitManager.habits.count)",
                    icon: "list.bullet",
                    color: .blue
                )
                
                AchievementCard(
                    title: "Taxa de Sucesso",
                    value: "\(Int(habitManager.averageCompletionRate * 100))%",
                    icon: "chart.line.uptrend.xyaxis",
                    color: .green
                )
            }
        }
    }
}

// MARK: - Achievement Card
struct AchievementCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 1, x: 0, y: 1)
    }
}

// MARK: - Settings Section
struct SettingsSection: View {
    @ObservedObject var habitManager: HabitManager
    @Binding var showingEditProfile: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Configurações")
                .font(.headline)
                .padding(.horizontal)
            
            VStack(spacing: 0) {
                SettingsRow(
                    icon: "person.circle",
                    title: "Editar Perfil",
                    action: { showingEditProfile = true }
                )
                
                Divider()
                
                SettingsRow(
                    icon: "bell",
                    title: "Notificações",
                    subtitle: habitManager.userProfile.notifications ? "Ativadas" : "Desativadas"
                )
                
                Divider()
                
                SettingsRow(
                    icon: "target",
                    title: "Meta Diária",
                    subtitle: "\(habitManager.userProfile.dailyGoal) hábitos"
                )
                
                Divider()
                
                SettingsRow(
                    icon: "calendar",
                    title: "Meta Semanal",
                    subtitle: "\(habitManager.userProfile.weeklyGoal) completações"
                )
            }
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.1), radius: 1, x: 0, y: 1)
        }
    }
}

// MARK: - Settings Row
struct SettingsRow: View {
    let icon: String
    let title: String
    let subtitle: String?
    let action: (() -> Void)?
    
    init(icon: String, title: String, subtitle: String? = nil, action: (() -> Void)? = nil) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self.action = action
    }
    
    var body: some View {
        Button(action: action ?? {}) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(.blue)
                    .frame(width: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.body)
                        .foregroundColor(.primary)
                    
                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                if action != nil {
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Edit Profile Sheet
struct EditProfileSheet: View {
    @ObservedObject var habitManager: HabitManager
    @Environment(\.presentationMode) var presentationMode
    
    @State private var name: String
    @State private var dailyGoal: Int
    @State private var weeklyGoal: Int
    @State private var notifications: Bool
    
    init(habitManager: HabitManager) {
        self.habitManager = habitManager
        self._name = State(initialValue: habitManager.userProfile.name)
        self._dailyGoal = State(initialValue: habitManager.userProfile.dailyGoal)
        self._weeklyGoal = State(initialValue: habitManager.userProfile.weeklyGoal)
        self._notifications = State(initialValue: habitManager.userProfile.notifications)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Informações Pessoais") {
                    TextField("Nome", text: $name)
                }
                
                Section("Metas") {
                    HStack {
                        Text("Meta diária:")
                        Spacer()
                        Stepper("\(dailyGoal) hábitos", value: $dailyGoal, in: 1...10)
                    }
                    
                    HStack {
                        Text("Meta semanal:")
                        Spacer()
                        Stepper("\(weeklyGoal) completações", value: $weeklyGoal, in: 1...70)
                    }
                }
                
                Section("Preferências") {
                    Toggle("Notificações", isOn: $notifications)
                }
            }
            .navigationTitle("Editar Perfil")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Salvar") {
                        var updatedProfile = habitManager.userProfile
                        updatedProfile.name = name
                        updatedProfile.dailyGoal = dailyGoal
                        updatedProfile.weeklyGoal = weeklyGoal
                        updatedProfile.notifications = notifications
                        
                        habitManager.updateProfile(updatedProfile)
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}

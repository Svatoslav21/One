import SwiftUI

struct SettingsView: View {
    @AppStorage("isDarkMode") private var isDarkMode = false
    @AppStorage("reminderEnabled") private var reminderEnabled = false
    @AppStorage("reminderHour") private var reminderHour = 20
    @AppStorage("reminderMinute") private var reminderMinute = 0
    @AppStorage("userName") private var userName = ""
    @AppStorage("energyGoal") private var energyGoal = 7

    private var reminderTime: Binding<Date> {
        Binding(
            get: {
                var components = DateComponents()
                components.hour = reminderHour
                components.minute = reminderMinute
                return Calendar.current.date(from: components) ?? Date()
            },
            set: { newValue in
                let components = Calendar.current.dateComponents([.hour, .minute], from: newValue)
                reminderHour = components.hour ?? 20
                reminderMinute = components.minute ?? 0
            }
        )
    }

    var body: some View {
        List {
            Section("Profile") {
                HStack {
                    Label("Name", systemImage: "person.fill")
                    Spacer()
                    Text(userName.isEmpty ? "Not set" : userName)
                        .foregroundStyle(.secondary)
                }

                HStack {
                    Label("Energy Goal", systemImage: "target")
                    Spacer()
                    Text("\(energyGoal)/10")
                        .foregroundStyle(.teal)
                        .fontWeight(.semibold)
                }
            }

            Section("Appearance") {
                Toggle(isOn: $isDarkMode) {
                    Label("Dark Mode", systemImage: isDarkMode ? "moon.fill" : "sun.max.fill")
                }
                .tint(.teal)
            }

            Section("Notifications") {
                Toggle(isOn: $reminderEnabled) {
                    Label("Daily Reminder", systemImage: "bell.fill")
                }
                .tint(.teal)

                if reminderEnabled {
                    DatePicker(
                        selection: reminderTime,
                        displayedComponents: .hourAndMinute
                    ) {
                        Label("Reminder Time", systemImage: "clock.fill")
                    }
                }
            }

            Section("About") {
                HStack {
                    Label("Version", systemImage: "info.circle")
                    Spacer()
                    Text("1.0.0")
                        .foregroundStyle(.secondary)
                }

                HStack {
                    Label("Developer", systemImage: "person.fill")
                    Spacer()
                    Text("Sadyg Sadygov")
                        .foregroundStyle(.secondary)
                }

                HStack {
                    Label("Built with", systemImage: "swift")
                    Spacer()
                    Text("SwiftUI + SwiftData")
                        .foregroundStyle(.secondary)
                }
            }

            Section {
                Button(role: .destructive) {
                    UserDefaults.standard.set(false, forKey: "hasCompletedOnboarding")
                } label: {
                    Label("Reset Onboarding", systemImage: "arrow.counterclockwise")
                }
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
}

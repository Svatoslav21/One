import SwiftUI
import SwiftData

struct LogEntrySheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let existingLog: EnergyLog?

    @State private var energyLevel: Int = 5
    @State private var selectedMood: MoodType = .neutral
    @State private var sleepHours: Double = 7.0
    @State private var selectedActivities: Set<ActivityType> = []
    @State private var selectedWeather: WeatherType = .sunny
    @State private var notes: String = ""
    @State private var bounceEnergy = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    energySection
                    moodSection
                    sleepSection
                    activitySection
                    weatherSection
                    notesSection
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 30)
                .padding(.top, 8)
            }
            .background(
                LinearGradient(
                    colors: [Color.teal.opacity(0.05), Color(.systemBackground)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            )
            .navigationTitle(existingLog != nil ? "Edit Entry" : "New Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveEntry()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .foregroundStyle(.teal)
                }
            }
            .onAppear {
                if let log = existingLog {
                    energyLevel = log.energyLevel
                    selectedMood = log.mood
                    sleepHours = log.sleepHours
                    selectedActivities = Set(log.activities)
                    selectedWeather = log.weather
                    notes = log.notes
                }
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }

    private var energySection: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .stroke(Color(.systemGray5), lineWidth: 14)
                    .frame(width: 140, height: 140)

                Circle()
                    .trim(from: 0, to: CGFloat(energyLevel) / 10.0)
                    .stroke(
                        AngularGradient(
                            gradient: Gradient(colors: [.teal, .cyan, .teal.opacity(0.6)]),
                            center: .center,
                            startAngle: .degrees(-90),
                            endAngle: .degrees(270)
                        ),
                        style: StrokeStyle(lineWidth: 14, lineCap: .round)
                    )
                    .frame(width: 140, height: 140)
                    .rotationEffect(.degrees(-90))
                    .animation(.spring(response: 0.5, dampingFraction: 0.8), value: energyLevel)

                VStack(spacing: 2) {
                    Text("\(energyLevel)")
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(colors: [.teal, .cyan], startPoint: .leading, endPoint: .trailing)
                        )
                        .contentTransition(.numericText())
                        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: energyLevel)
                    Text("energy")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .bounce(trigger: bounceEnergy)
            }

            Slider(value: Binding(
                get: { Double(energyLevel) },
                set: { newVal in
                    let newLevel = Int(newVal)
                    if newLevel != energyLevel {
                        energyLevel = newLevel
                        bounceEnergy.toggle()
                    }
                }
            ), in: 1...10, step: 1)
            .tint(.teal)
            .padding(.horizontal, 16)
        }
        .padding(20)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    private var moodSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Mood")
                .font(.headline)

            HStack(spacing: 0) {
                ForEach(MoodType.allCases) { mood in
                    Button {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                            selectedMood = mood
                        }
                    } label: {
                        VStack(spacing: 4) {
                            Text(mood.emoji)
                                .font(.system(size: 28))
                                .scaleEffect(selectedMood == mood ? 1.2 : 1.0)
                            Text(mood.displayName)
                                .font(.system(size: 9))
                                .foregroundStyle(selectedMood == mood ? .teal : .secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(
                            selectedMood == mood ?
                                AnyShapeStyle(LinearGradient(colors: [.teal.opacity(0.15), .cyan.opacity(0.1)], startPoint: .top, endPoint: .bottom)) :
                                AnyShapeStyle(Color.clear)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .buttonStyle(PressableButtonStyle())
                }
            }
        }
        .padding(16)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    private var sleepSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Sleep")
                .font(.headline)

            HStack {
                Image(systemName: "moon.fill")
                    .foregroundStyle(.indigo)

                Slider(value: $sleepHours, in: 0...14, step: 0.5)
                    .tint(.indigo)

                Text(String(format: "%.1f h", sleepHours))
                    .font(.headline)
                    .monospacedDigit()
                    .frame(width: 56)
            }
        }
        .padding(16)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    private var activitySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Activities")
                .font(.headline)

            FlowLayout(spacing: 8) {
                ForEach(ActivityType.allCases) { activity in
                    let isSelected = selectedActivities.contains(activity)
                    Button {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                            if isSelected {
                                selectedActivities.remove(activity)
                            } else {
                                selectedActivities.insert(activity)
                            }
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: activity.iconName)
                                .font(.caption)
                            Text(activity.displayName)
                                .font(.subheadline.weight(.medium))
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(
                            isSelected ?
                                AnyShapeStyle(LinearGradient(colors: [.teal, .cyan], startPoint: .leading, endPoint: .trailing)) :
                                AnyShapeStyle(Color(.systemGray5))
                        )
                        .foregroundStyle(isSelected ? .white : .primary)
                        .clipShape(Capsule())
                    }
                    .buttonStyle(PressableButtonStyle())
                }
            }
        }
        .padding(16)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    private var weatherSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Weather")
                .font(.headline)

            HStack(spacing: 0) {
                ForEach(WeatherType.allCases) { weather in
                    Button {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                            selectedWeather = weather
                        }
                    } label: {
                        VStack(spacing: 4) {
                            Image(systemName: weather.iconName)
                                .font(.title2)
                                .foregroundStyle(selectedWeather == weather ? .teal : .secondary)
                            Text(weather.displayName)
                                .font(.caption2)
                                .foregroundStyle(selectedWeather == weather ? .teal : .secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(selectedWeather == weather ? Color.teal.opacity(0.15) : Color.clear)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .buttonStyle(PressableButtonStyle())
                }
            }
        }
        .padding(16)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    private var notesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Notes")
                .font(.headline)

            TextField("How was your day?", text: $notes, axis: .vertical)
                .lineLimit(3...6)
                .padding(12)
                .background(Color(.systemGray5).opacity(0.5))
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .padding(16)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    private func saveEntry() {
        if let existing = existingLog {
            existing.energyLevel = energyLevel
            existing.mood = selectedMood
            existing.sleepHours = sleepHours
            existing.activities = Array(selectedActivities)
            existing.weather = selectedWeather
            existing.notes = notes
        } else {
            let newLog = EnergyLog(
                energyLevel: energyLevel,
                mood: selectedMood,
                sleepHours: sleepHours,
                activities: Array(selectedActivities),
                notes: notes,
                weather: selectedWeather
            )
            modelContext.insert(newLog)
        }
    }
}

#Preview {
    LogEntrySheet(existingLog: nil)
        .modelContainer(for: [EnergyLog.self, Streak.self], inMemory: true)
}

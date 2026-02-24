import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \EnergyLog.date, order: .reverse) private var allLogs: [EnergyLog]
    @Query(filter: #Predicate<Streak> { $0.endDate == nil }) private var activeStreaks: [Streak]

    @State private var showingLogSheet = false
    @State private var showingSettings = false
    @State private var selectedDate: Date = Date()
    @State private var ringAnimated = false

    private var todayLog: EnergyLog? {
        let calendar = Calendar.current
        return allLogs.first { calendar.isDate($0.date, inSameDayAs: selectedDate) }
    }

    private var weekDates: [Date] {
        let calendar = Calendar.current
        let today = Date()
        return (-3...3).compactMap { offset in
            calendar.date(byAdding: .day, value: offset, to: today)
        }
    }

    private var last30DaysLogs: [EnergyLog] {
        let cutoff = Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date()
        return allLogs.filter { $0.date >= cutoff }
    }

    private var averageEnergy: Double {
        guard !last30DaysLogs.isEmpty else { return 0 }
        return Double(last30DaysLogs.map(\.energyLevel).reduce(0, +)) / Double(last30DaysLogs.count)
    }

    private var dominantMood: MoodType {
        let counts = Dictionary(grouping: last30DaysLogs, by: { $0.mood })
        return counts.max(by: { $0.value.count < $1.value.count })?.key ?? .neutral
    }

    private var averageSleep: Double {
        guard !last30DaysLogs.isEmpty else { return 0 }
        return last30DaysLogs.map(\.sleepHours).reduce(0, +) / Double(last30DaysLogs.count)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    energyRingSection
                        .staggeredAppear(index: 0)

                    weekTimelineSection
                        .staggeredAppear(index: 1)

                    insightCardsGrid
                        .staggeredAppear(index: 2)

                    if !allLogs.isEmpty {
                        heatmapSection
                            .staggeredAppear(index: 3)
                    }

                    if let streak = activeStreaks.first {
                        streakBanner(streak)
                            .staggeredAppear(index: 4)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 30)
            }
            .background(
                LinearGradient(
                    colors: [Color.teal.opacity(0.05), Color.cyan.opacity(0.03), Color(.systemBackground)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            )
            .navigationTitle("Energy")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    HStack(spacing: 12) {
                        Button {
                            showingLogSheet = true
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                                .symbolRenderingMode(.hierarchical)
                                .foregroundStyle(.teal)
                        }

                        NavigationLink(destination: SettingsView()) {
                            Image(systemName: "gearshape.fill")
                                .foregroundStyle(.teal)
                        }
                    }
                }
            }
            .sheet(isPresented: $showingLogSheet) {
                LogEntrySheet(existingLog: todayLog)
            }
            .onAppear {
                withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) {
                    ringAnimated = true
                }
            }
        }
    }

    private var energyRingSection: some View {
        let currentLevel = todayLog?.energyLevel ?? 0
        let progress = CGFloat(currentLevel) / 10.0

        return VStack(spacing: 16) {
            ZStack {
                Circle()
                    .stroke(Color(.systemGray5), lineWidth: 20)

                Circle()
                    .trim(from: 0, to: ringAnimated ? progress : 0)
                    .stroke(
                        AngularGradient(
                            gradient: Gradient(colors: [.teal, .cyan, .teal.opacity(0.6)]),
                            center: .center,
                            startAngle: .degrees(-90),
                            endAngle: .degrees(270)
                        ),
                        style: StrokeStyle(lineWidth: 20, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .animation(.spring(response: 1.0, dampingFraction: 0.7), value: ringAnimated)
                    .animation(.spring(response: 0.6, dampingFraction: 0.8), value: currentLevel)

                VStack(spacing: 4) {
                    if currentLevel > 0 {
                        Text("\(currentLevel)")
                            .font(.system(size: 56, weight: .bold, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(colors: [.teal, .cyan], startPoint: .leading, endPoint: .trailing)
                            )
                            .contentTransition(.numericText())
                            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: currentLevel)
                    } else {
                        Text("--")
                            .font(.system(size: 56, weight: .bold, design: .rounded))
                            .foregroundStyle(.secondary)
                    }
                    Text("out of 10")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    if let log = todayLog {
                        Text(log.mood.emoji)
                            .font(.title2)
                    }
                }
            }
            .frame(width: 200, height: 200)

            if todayLog == nil {
                Button {
                    showingLogSheet = true
                } label: {
                    Text("Log Today's Energy")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 10)
                        .background(
                            LinearGradient(colors: [.teal, .cyan], startPoint: .leading, endPoint: .trailing)
                        )
                        .clipShape(Capsule())
                }
                .buttonStyle(PressableButtonStyle())
            } else {
                Text("Today: \(todayLog!.mood.displayName)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 8)
    }

    private var weekTimelineSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("This Week")
                .font(.headline)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(weekDates, id: \.self) { date in
                        let log = allLogs.first { Calendar.current.isDate($0.date, inSameDayAs: date) }
                        let isSelected = Calendar.current.isDate(date, inSameDayAs: selectedDate)
                        let isToday = Calendar.current.isDateInToday(date)

                        Button {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                selectedDate = date
                            }
                        } label: {
                            VStack(spacing: 6) {
                                Text(dayAbbreviation(date))
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)

                                ZStack {
                                    Circle()
                                        .fill(isSelected ?
                                            AnyShapeStyle(LinearGradient(colors: [.teal, .cyan], startPoint: .topLeading, endPoint: .bottomTrailing)) :
                                            AnyShapeStyle(Color(.systemGray6))
                                        )
                                        .frame(width: 44, height: 44)

                                    if let log = log {
                                        Text("\(log.energyLevel)")
                                            .font(.subheadline.bold())
                                            .foregroundStyle(isSelected ? .white : .primary)
                                    } else {
                                        Text(dayNumber(date))
                                            .font(.subheadline)
                                            .foregroundStyle(isSelected ? .white : .secondary)
                                    }
                                }

                                if let log = log {
                                    Text(log.mood.emoji)
                                        .font(.caption)
                                } else {
                                    Circle()
                                        .fill(Color.clear)
                                        .frame(width: 16, height: 16)
                                }

                                if isToday {
                                    Circle()
                                        .fill(Color.teal)
                                        .frame(width: 5, height: 5)
                                } else {
                                    Circle()
                                        .fill(Color.clear)
                                        .frame(width: 5, height: 5)
                                }
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 4)
            }
        }
        .padding(16)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    private var insightCardsGrid: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Insights")
                .font(.headline)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                GlassCard(
                    icon: "bolt.fill",
                    title: "Avg Energy",
                    value: last30DaysLogs.isEmpty ? "--" : String(format: "%.1f", averageEnergy),
                    color: .teal
                )

                GlassCard(
                    icon: dominantMood.iconName,
                    title: "Top Mood",
                    value: last30DaysLogs.isEmpty ? "--" : dominantMood.displayName,
                    color: .cyan
                )

                GlassCard(
                    icon: "moon.fill",
                    title: "Avg Sleep",
                    value: last30DaysLogs.isEmpty ? "--" : String(format: "%.1fh", averageSleep),
                    color: .indigo
                )

                GlassCard(
                    icon: "calendar",
                    title: "Entries",
                    value: "\(allLogs.count)",
                    color: .mint
                )
            }
        }
    }

    private var heatmapSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Energy Heatmap")
                    .font(.headline)
                Spacer()
                Text("Last 28 days")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            HeatmapCalendarView(logs: allLogs)
        }
        .padding(16)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    private func streakBanner(_ streak: Streak) -> some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(colors: [.orange, .red.opacity(0.8)], startPoint: .top, endPoint: .bottom)
                    )
                    .frame(width: 50, height: 50)

                Image(systemName: "flame.fill")
                    .font(.title2)
                    .foregroundStyle(.white)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(streak.name)
                    .font(.subheadline.bold())
                Text("\(streak.currentCount) day streak")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text("\(streak.currentCount)")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundStyle(
                    LinearGradient(colors: [.orange, .red], startPoint: .top, endPoint: .bottom)
                )
        }
        .padding(16)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    private func dayAbbreviation(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: date).uppercased()
    }

    private func dayNumber(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }
}

struct GlassCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)

            Text(value)
                .font(.title2.bold())
                .foregroundStyle(.primary)

            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

struct HeatmapCalendarView: View {
    let logs: [EnergyLog]

    private var last28Days: [Date] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        return (0..<28).compactMap { offset in
            calendar.date(byAdding: .day, value: -27 + offset, to: today)
        }
    }

    private func logForDate(_ date: Date) -> EnergyLog? {
        let calendar = Calendar.current
        return logs.first { calendar.isDate($0.date, inSameDayAs: date) }
    }

    private func cellColor(for level: Int) -> Color {
        switch level {
        case 1...2: return .red.opacity(0.6)
        case 3...4: return .orange.opacity(0.6)
        case 5...6: return .yellow.opacity(0.5)
        case 7...8: return .teal.opacity(0.6)
        case 9...10: return .teal
        default: return Color(.systemGray5)
        }
    }

    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: 7), spacing: 4) {
            ForEach(last28Days, id: \.self) { date in
                let log = logForDate(date)
                let level = log?.energyLevel ?? 0

                RoundedRectangle(cornerRadius: 4)
                    .fill(cellColor(for: level))
                    .aspectRatio(1, contentMode: .fit)
                    .overlay(
                        Group {
                            if Calendar.current.isDateInToday(date) {
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(Color.teal, lineWidth: 2)
                            }
                        }
                    )
            }
        }

        HStack(spacing: 4) {
            Text("Low")
                .font(.system(size: 9))
                .foregroundStyle(.secondary)
            ForEach([2, 4, 6, 8, 10], id: \.self) { level in
                RoundedRectangle(cornerRadius: 2)
                    .fill(cellColor(for: level))
                    .frame(width: 12, height: 12)
            }
            Text("High")
                .font(.system(size: 9))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .trailing)
    }
}

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = layout(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = layout(proposal: proposal, subviews: subviews)
        for (index, position) in result.positions.enumerated() {
            subviews[index].place(at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y), proposal: .unspecified)
        }
    }

    private func layout(proposal: ProposedViewSize, subviews: Subviews) -> (size: CGSize, positions: [CGPoint]) {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var lineHeight: CGFloat = 0
        var totalHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if currentX + size.width > maxWidth, currentX > 0 {
                currentX = 0
                currentY += lineHeight + spacing
                lineHeight = 0
            }
            positions.append(CGPoint(x: currentX, y: currentY))
            lineHeight = max(lineHeight, size.height)
            currentX += size.width + spacing
            totalHeight = currentY + lineHeight
        }

        return (CGSize(width: maxWidth, height: totalHeight), positions)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [EnergyLog.self, Streak.self], inMemory: true)
}

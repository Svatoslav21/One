import Foundation
import SwiftData

@Model
final class EnergyLog {
    var id: UUID
    var date: Date
    var energyLevel: Int
    var moodRaw: String
    var sleepHours: Double
    var activityRaws: [String]
    var notes: String
    var weatherRaw: String

    var mood: MoodType {
        get { MoodType(rawValue: moodRaw) ?? .neutral }
        set { moodRaw = newValue.rawValue }
    }

    var activities: [ActivityType] {
        get { activityRaws.compactMap { ActivityType(rawValue: $0) } }
        set { activityRaws = newValue.map(\.rawValue) }
    }

    var weather: WeatherType {
        get { WeatherType(rawValue: weatherRaw) ?? .sunny }
        set { weatherRaw = newValue.rawValue }
    }

    init(
        energyLevel: Int = 5,
        mood: MoodType = .neutral,
        sleepHours: Double = 7.0,
        activities: [ActivityType] = [],
        notes: String = "",
        weather: WeatherType = .sunny
    ) {
        self.id = UUID()
        self.date = Date()
        self.energyLevel = energyLevel
        self.moodRaw = mood.rawValue
        self.sleepHours = sleepHours
        self.activityRaws = activities.map(\.rawValue)
        self.notes = notes
        self.weatherRaw = weather.rawValue
    }
}

import Foundation
import SwiftData

@Model
final class Streak {
    var id: UUID
    var name: String
    var startDate: Date
    var endDate: Date?
    var targetMoodRaw: String
    var currentCount: Int

    var targetMood: MoodType {
        get { MoodType(rawValue: targetMoodRaw) ?? .joyful }
        set { targetMoodRaw = newValue.rawValue }
    }

    var isActive: Bool {
        endDate == nil
    }

    init(
        name: String,
        targetMood: MoodType = .joyful,
        currentCount: Int = 0
    ) {
        self.id = UUID()
        self.name = name
        self.startDate = Date()
        self.endDate = nil
        self.targetMoodRaw = targetMood.rawValue
        self.currentCount = currentCount
    }
}

import Foundation

enum MoodType: String, Codable, CaseIterable, Identifiable {
    case joyful
    case calm
    case neutral
    case anxious
    case sad
    case angry

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .joyful: "Joyful"
        case .calm: "Calm"
        case .neutral: "Neutral"
        case .anxious: "Anxious"
        case .sad: "Sad"
        case .angry: "Angry"
        }
    }

    var emoji: String {
        switch self {
        case .joyful: "😄"
        case .calm: "😌"
        case .neutral: "😐"
        case .anxious: "😰"
        case .sad: "😢"
        case .angry: "😡"
        }
    }

    var iconName: String {
        switch self {
        case .joyful: "sun.max.fill"
        case .calm: "leaf.fill"
        case .neutral: "circle.fill"
        case .anxious: "bolt.fill"
        case .sad: "cloud.rain.fill"
        case .angry: "flame.fill"
        }
    }
}

enum ActivityType: String, Codable, CaseIterable, Identifiable {
    case exercise
    case socializing
    case work
    case nature
    case creative
    case rest
    case reading
    case meditation

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .exercise: "Exercise"
        case .socializing: "Socializing"
        case .work: "Work"
        case .nature: "Nature"
        case .creative: "Creative"
        case .rest: "Rest"
        case .reading: "Reading"
        case .meditation: "Meditation"
        }
    }

    var iconName: String {
        switch self {
        case .exercise: "figure.run"
        case .socializing: "person.2.fill"
        case .work: "briefcase.fill"
        case .nature: "leaf.fill"
        case .creative: "paintbrush.fill"
        case .rest: "bed.double.fill"
        case .reading: "book.fill"
        case .meditation: "brain.head.profile.fill"
        }
    }
}

enum WeatherType: String, Codable, CaseIterable, Identifiable {
    case sunny
    case cloudy
    case rainy
    case snowy
    case stormy

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .sunny: "Sunny"
        case .cloudy: "Cloudy"
        case .rainy: "Rainy"
        case .snowy: "Snowy"
        case .stormy: "Stormy"
        }
    }

    var iconName: String {
        switch self {
        case .sunny: "sun.max.fill"
        case .cloudy: "cloud.fill"
        case .rainy: "cloud.rain.fill"
        case .snowy: "cloud.snow.fill"
        case .stormy: "cloud.bolt.fill"
        }
    }
}

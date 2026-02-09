import SwiftUI

enum WatchType: String, CaseIterable, Identifiable {
    case show = "show"
    case movie = "movie"

    var id: String { rawValue }

    var label: String {
        switch self {
        case .show: "TV Show"
        case .movie: "Movie"
        }
    }

    var systemImage: String {
        switch self {
        case .show: "tv"
        case .movie: "film"
        }
    }
}

enum WatchStatus: String, CaseIterable, Identifiable {
    case watching = "watching"
    case onHold = "onHold"
    case finished = "finished"
    case rewatching = "rewatching"

    var id: String { rawValue }

    var label: String {
        switch self {
        case .watching: "Watching"
        case .onHold: "On Hold"
        case .finished: "Finished"
        case .rewatching: "Rewatching"
        }
    }

    var systemImage: String {
        switch self {
        case .watching: "play.circle"
        case .onHold: "pause.circle"
        case .finished: "checkmark.circle"
        case .rewatching: "arrow.counterclockwise.circle"
        }
    }
}

// MARK: - Row Density

enum RowDensity: String, CaseIterable, Identifiable {
    case compact = "compact"
    case comfortable = "comfortable"

    var id: String { rawValue }

    var label: String {
        switch self {
        case .compact: "Compact"
        case .comfortable: "Comfortable"
        }
    }

    var verticalPadding: CGFloat {
        switch self {
        case .compact: 2
        case .comfortable: 6
        }
    }
}

// MARK: - Accent Color

enum AppAccentColor: String, CaseIterable, Identifiable {
    case system = "system"
    case teal = "teal"
    case blue = "blue"
    case purple = "purple"
    case orange = "orange"

    var id: String { rawValue }

    var label: String {
        switch self {
        case .system: "System"
        case .teal: "Teal"
        case .blue: "Blue"
        case .purple: "Purple"
        case .orange: "Orange"
        }
    }

    var color: Color? {
        switch self {
        case .system: nil
        case .teal: .teal
        case .blue: .blue
        case .purple: .purple
        case .orange: .orange
        }
    }
}

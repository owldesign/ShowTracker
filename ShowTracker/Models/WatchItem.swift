import Foundation
import SwiftData

@Model
final class WatchItem {
    #Index<WatchItem>([\.title], [\.statusRawValue, \.typeRawValue, \.lastUpdatedAt])

    @Attribute(.unique) var id: UUID
    var title: String
    var typeRawValue: String
    var statusRawValue: String
    var seasonNumber: Int
    var episodeNumber: Int
    var timestampSeconds: Int?
    var notes: String
    var createdAt: Date
    var lastUpdatedAt: Date

    var type: WatchType {
        get { WatchType(rawValue: typeRawValue) ?? .show }
        set { typeRawValue = newValue.rawValue }
    }

    var status: WatchStatus {
        get { WatchStatus(rawValue: statusRawValue) ?? .watching }
        set { statusRawValue = newValue.rawValue }
    }

    var progressString: String {
        switch type {
        case .show:
            return "S\(seasonNumber) E\(episodeNumber)"
        case .movie:
            if let ts = timestampSeconds {
                let h = ts / 3600
                let m = (ts % 3600) / 60
                let s = ts % 60
                return String(format: "%02d:%02d:%02d", h, m, s)
            }
            return ""
        }
    }

    init(
        title: String,
        type: WatchType,
        status: WatchStatus = .watching,
        seasonNumber: Int = 1,
        episodeNumber: Int = 1,
        timestampSeconds: Int? = nil,
        notes: String = ""
    ) {
        self.id = UUID()
        self.title = title
        self.typeRawValue = type.rawValue
        self.statusRawValue = status.rawValue
        self.seasonNumber = seasonNumber
        self.episodeNumber = episodeNumber
        self.timestampSeconds = timestampSeconds
        self.notes = notes
        self.createdAt = Date.now
        self.lastUpdatedAt = Date.now
    }

    func incrementEpisode() {
        episodeNumber += 1
        lastUpdatedAt = Date.now
    }

    func incrementSeason() {
        seasonNumber += 1
        episodeNumber = 1
        lastUpdatedAt = Date.now
    }

    func markFinished() {
        statusRawValue = WatchStatus.finished.rawValue
        lastUpdatedAt = Date.now
    }

    func startRewatching() {
        statusRawValue = WatchStatus.rewatching.rawValue
        seasonNumber = 1
        episodeNumber = 1
        timestampSeconds = nil
        lastUpdatedAt = Date.now
    }
}

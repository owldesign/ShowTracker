import SwiftUI
import SwiftData

struct WatchItemDetailView: View {
    let itemID: PersistentIdentifier
    let onEdit: (WatchItem) -> Void

    @Environment(\.modelContext) private var modelContext

    @Query private var items: [WatchItem]

    private var item: WatchItem? {
        items.first { $0.persistentModelID == itemID }
    }

    var body: some View {
        if let item {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    headerSection(item)
                    Divider()
                    quickActionsSection(item)
                    Divider()
                    detailsSection(item)

                    if !item.notes.isEmpty {
                        Divider()
                        notesSection(item)
                    }
                }
                .padding()
            }
        } else {
            ContentUnavailableView(
                "Item Not Found",
                systemImage: "questionmark.circle"
            )
        }
    }

    @ViewBuilder
    private func headerSection(_ item: WatchItem) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Label(item.type.label, systemImage: item.type.systemImage)
                .font(.caption)
                .foregroundStyle(.secondary)

            Text(item.title)
                .font(.title2.bold())

            Label(item.status.label, systemImage: item.status.systemImage)
                .font(.subheadline)
                .foregroundStyle(.blue)
        }
    }

    @ViewBuilder
    private func quickActionsSection(_ item: WatchItem) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Quick Actions")
                .font(.headline)

            HStack(spacing: 8) {
                if item.type == .show && item.status != .finished {
                    Button("Next Episode") {
                        item.incrementEpisode()
                    }

                    Button("Next Season") {
                        item.incrementSeason()
                    }
                }

                if item.status != .finished {
                    Button("Mark Finished") {
                        item.markFinished()
                    }
                }

                if item.status == .finished {
                    Button("Rewatch") {
                        item.startRewatching()
                    }
                }

                Button("Edit") {
                    onEdit(item)
                }
            }
            .buttonStyle(.bordered)
        }
    }

    @ViewBuilder
    private func detailsSection(_ item: WatchItem) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Progress")
                .font(.headline)

            if item.type == .show {
                LabeledContent("Season", value: "\(item.seasonNumber)")
                LabeledContent("Episode", value: "\(item.episodeNumber)")
            } else if item.timestampSeconds != nil {
                LabeledContent("Timestamp", value: item.progressString)
            }

            LabeledContent("Last Updated") {
                Text(item.lastUpdatedAt, style: .date)
            }
            LabeledContent("Added") {
                Text(item.createdAt, style: .date)
            }
        }
    }

    @ViewBuilder
    private func notesSection(_ item: WatchItem) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Notes")
                .font(.headline)
            Text(item.notes)
                .font(.body)
                .foregroundStyle(.secondary)
        }
    }
}

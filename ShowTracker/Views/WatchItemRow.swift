import SwiftUI
import SwiftData

struct WatchItemRow: View {
    let item: WatchItem
    @AppStorage("rowDensity") private var rowDensity: String = RowDensity.comfortable.rawValue

    private var density: RowDensity {
        RowDensity(rawValue: rowDensity) ?? .comfortable
    }

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: item.type.systemImage)
                .foregroundStyle(.secondary)
                .frame(width: 20)

            VStack(alignment: .leading, spacing: 2) {
                Text(item.title)
                    .font(.body)
                    .lineLimit(1)

                HStack(spacing: 6) {
                    if !item.progressString.isEmpty {
                        Text(item.progressString)
                            .font(.caption)
                            .foregroundStyle(.blue)

                        Text("\u{00B7}")
                            .foregroundStyle(.quaternary)
                    }

                    Text(item.lastUpdatedAt, style: .relative)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            Image(systemName: item.status.systemImage)
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, density.verticalPadding)
    }
}

#Preview {
    List {
        WatchItemRow(item: WatchItem(title: "Breaking Bad", type: .show, seasonNumber: 3, episodeNumber: 7))
        WatchItemRow(item: WatchItem(title: "Inception", type: .movie, timestampSeconds: 4353))
        WatchItemRow(item: WatchItem(title: "The Office", type: .show, status: .finished, seasonNumber: 9, episodeNumber: 23))
    }
    .frame(width: 400)
}

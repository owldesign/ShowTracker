import SwiftUI
import SwiftData

struct SidebarView: View {
    @Binding var statusFilter: WatchStatus?
    @Binding var typeFilter: WatchType?

    @Query private var allItems: [WatchItem]

    var body: some View {
        List {
            Section("Status") {
                SidebarRow(
                    label: "All",
                    systemImage: "tray.full",
                    badge: allItems.count,
                    isSelected: statusFilter == nil
                ) {
                    statusFilter = nil
                }

                ForEach(WatchStatus.allCases) { status in
                    SidebarRow(
                        label: status.label,
                        systemImage: status.systemImage,
                        badge: allItems.filter { $0.statusRawValue == status.rawValue }.count,
                        isSelected: statusFilter == status
                    ) {
                        statusFilter = status
                    }
                }
            }

            Section("Type") {
                SidebarRow(
                    label: "All Types",
                    systemImage: "square.grid.2x2",
                    badge: nil,
                    isSelected: typeFilter == nil
                ) {
                    typeFilter = nil
                }

                ForEach(WatchType.allCases) { type in
                    SidebarRow(
                        label: type.label,
                        systemImage: type.systemImage,
                        badge: allItems.filter { $0.typeRawValue == type.rawValue }.count,
                        isSelected: typeFilter == type
                    ) {
                        typeFilter = type
                    }
                }
            }
        }
        .listStyle(.sidebar)
        .navigationTitle("ShowTracker")
    }
}

private struct SidebarRow: View {
    let label: String
    let systemImage: String
    let badge: Int?
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Label(label, systemImage: systemImage)
                Spacer()
                if let badge, badge > 0 {
                    Text("\(badge)")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(.quaternary, in: Capsule())
                }
            }
        }
        .buttonStyle(.plain)
        .fontWeight(isSelected ? .semibold : .regular)
    }
}

#Preview {
    SidebarView(
        statusFilter: .constant(nil),
        typeFilter: .constant(nil)
    )
    .modelContainer(previewContainer)
}

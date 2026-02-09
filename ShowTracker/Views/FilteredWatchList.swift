import SwiftUI
import SwiftData

struct FilteredWatchList: View {
    @Query private var items: [WatchItem]
    @Binding var selection: PersistentIdentifier?

    @Environment(\.modelContext) private var modelContext
    @State private var itemToDelete: WatchItem?

    init(
        searchText: String,
        statusFilter: WatchStatus?,
        typeFilter: WatchType?,
        selection: Binding<PersistentIdentifier?>
    ) {
        let statusRaw = statusFilter?.rawValue
        let typeRaw = typeFilter?.rawValue

        self._items = Query(
            filter: #Predicate<WatchItem> { item in
                (searchText.isEmpty || item.title.localizedStandardContains(searchText))
                && (statusRaw == nil || item.statusRawValue == statusRaw!)
                && (typeRaw == nil || item.typeRawValue == typeRaw!)
            },
            sort: [SortDescriptor(\WatchItem.lastUpdatedAt, order: .reverse)]
        )
        self._selection = selection
    }

    var body: some View {
        List(selection: $selection) {
            ForEach(items) { item in
                WatchItemRow(item: item)
                    .tag(item.persistentModelID)
                    .contextMenu {
                        if item.type == .show && item.status != .finished {
                            Button("Next Episode") {
                                item.incrementEpisode()
                            }
                            Button("Next Season") {
                                item.incrementSeason()
                            }
                            Divider()
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

                        Divider()

                        Button("Delete", role: .destructive) {
                            itemToDelete = item
                        }
                    }
            }
            .onDelete { indexSet in
                if let first = indexSet.first {
                    itemToDelete = items[first]
                }
            }
        }
        .overlay {
            if items.isEmpty {
                ContentUnavailableView(
                    "No Items",
                    systemImage: "tv.slash",
                    description: Text("Add a show or movie to get started.\nPress \u{2318}N to add one.")
                )
            }
        }
        .confirmationDialog(
            "Delete \"\(itemToDelete?.title ?? "")\"?",
            isPresented: Binding(
                get: { itemToDelete != nil },
                set: { if !$0 { itemToDelete = nil } }
            ),
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                if let itemToDelete {
                    if selection == itemToDelete.persistentModelID {
                        selection = nil
                    }
                    modelContext.delete(itemToDelete)
                }
                itemToDelete = nil
            }
        } message: {
            Text("This action cannot be undone.")
        }
    }
}

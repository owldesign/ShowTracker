import SwiftUI
import SwiftData

struct WatchListContainer: View {
    @Binding var searchText: String
    let statusFilter: WatchStatus?
    let typeFilter: WatchType?
    @Binding var selectedItemID: PersistentIdentifier?
    @Binding var showInspector: Bool
    @Binding var showAddSheet: Bool
    @Binding var editingItem: WatchItem?

    var body: some View {
        FilteredWatchList(
            searchText: searchText,
            statusFilter: statusFilter,
            typeFilter: typeFilter,
            selection: $selectedItemID
        )
        .searchable(text: $searchText, prompt: "Search shows and movies...")
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                Button {
                    editingItem = nil
                    showAddSheet = true
                } label: {
                    Label("Add Item", systemImage: "plus")
                }
                .keyboardShortcut("n", modifiers: .command)

                Button {
                    showInspector.toggle()
                } label: {
                    Label("Toggle Inspector", systemImage: "sidebar.trailing")
                }
                .keyboardShortcut("i", modifiers: [.command, .option])
            }
        }
        .inspector(isPresented: $showInspector) {
            Group {
                if let selectedItemID {
                    WatchItemDetailView(
                        itemID: selectedItemID,
                        onEdit: { item in
                            editingItem = item
                            showAddSheet = true
                        }
                    )
                } else {
                    ContentUnavailableView(
                        "No Selection",
                        systemImage: "tv",
                        description: Text("Select an item to see details.")
                    )
                }
            }
            .inspectorColumnWidth(min: 250, ideal: 300, max: 400)
        }
        .navigationTitle(navigationTitle)
    }

    private var navigationTitle: String {
        if let status = statusFilter {
            return status.label
        }
        if let type = typeFilter {
            return type.label
        }
        return "All Items"
    }
}

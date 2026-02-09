import SwiftUI
import SwiftData

struct ContentView: View {
    @Query private var allItems: [WatchItem]
    @State private var selectedItemID: PersistentIdentifier?
    @State private var searchText = ""
    @State private var statusFilter: WatchStatus? = nil
    @State private var typeFilter: WatchType? = nil
    @State private var showInspector = true
    @State private var showAddSheet = false
    @State private var editingItem: WatchItem? = nil

    private var selectedItem: WatchItem? {
        guard let selectedItemID else { return nil }
        return allItems.first { $0.persistentModelID == selectedItemID }
    }

    var body: some View {
        NavigationSplitView {
            SidebarView(
                statusFilter: $statusFilter,
                typeFilter: $typeFilter
            )
        } detail: {
            WatchListContainer(
                searchText: $searchText,
                statusFilter: statusFilter,
                typeFilter: typeFilter,
                selectedItemID: $selectedItemID,
                showInspector: $showInspector,
                showAddSheet: $showAddSheet,
                editingItem: $editingItem
            )
        }
        .navigationSplitViewColumnWidth(min: 180, ideal: 200, max: 250)
        .sheet(isPresented: $showAddSheet) {
            AddEditSheet(item: editingItem)
        }
        .focusedSceneValue(\.triggerAddItem) {
            editingItem = nil
            showAddSheet = true
        }
        .focusedSceneValue(\.triggerIncrementEpisode, selectedItem?.type == .show && selectedItem?.status != .finished ? {
            selectedItem?.incrementEpisode()
        } : nil)
        .focusedSceneValue(\.triggerMarkFinished, selectedItem != nil && selectedItem?.status != .finished ? {
            selectedItem?.markFinished()
        } : nil)
        .focusedSceneValue(\.triggerEditItem, selectedItem != nil ? {
            if let selectedItem {
                editingItem = selectedItem
                showAddSheet = true
            }
        } : nil)
    }
}

#Preview {
    ContentView()
        .modelContainer(previewContainer)
}

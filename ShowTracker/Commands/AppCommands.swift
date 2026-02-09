import SwiftUI
import SwiftData

// MARK: - Focused Values

extension FocusedValues {
    @Entry var triggerAddItem: (() -> Void)?
    @Entry var triggerIncrementEpisode: (() -> Void)?
    @Entry var triggerMarkFinished: (() -> Void)?
    @Entry var triggerEditItem: (() -> Void)?
}

// MARK: - App Commands

struct AppCommands: Commands {
    let updaterController: UpdaterController

    @FocusedValue(\.triggerAddItem) var triggerAddItem
    @FocusedValue(\.triggerIncrementEpisode) var triggerIncrementEpisode
    @FocusedValue(\.triggerMarkFinished) var triggerMarkFinished
    @FocusedValue(\.triggerEditItem) var triggerEditItem

    var body: some Commands {
        CommandGroup(after: .appInfo) {
            Button("Check for Updates...") {
                updaterController.checkForUpdates()
            }
            .disabled(!updaterController.canCheckForUpdates)
        }

        CommandGroup(replacing: .newItem) {
            Button("New Item") {
                triggerAddItem?()
            }
            .keyboardShortcut("n", modifiers: .command)
        }

        CommandMenu("Show") {
            Button("Next Episode") {
                triggerIncrementEpisode?()
            }
            .keyboardShortcut(.return, modifiers: .command)
            .disabled(triggerIncrementEpisode == nil)

            Button("Mark Finished") {
                triggerMarkFinished?()
            }
            .keyboardShortcut(.delete, modifiers: .command)
            .disabled(triggerMarkFinished == nil)

            Divider()

            Button("Edit Item") {
                triggerEditItem?()
            }
            .keyboardShortcut("e", modifiers: .command)
            .disabled(triggerEditItem == nil)
        }
    }
}

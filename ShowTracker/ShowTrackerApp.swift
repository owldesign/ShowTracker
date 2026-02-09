import SwiftUI
import SwiftData

@main
struct ShowTrackerApp: App {
    let container: ModelContainer
    @State private var updaterController = UpdaterController()
    @AppStorage("accentColor") private var accentColor: String = AppAccentColor.system.rawValue

    private var selectedAccentColor: Color? {
        AppAccentColor(rawValue: accentColor)?.color
    }

    init() {
        do {
            let config = ModelConfiguration("ShowTracker")
            container = try ModelContainer(
                for: WatchItem.self,
                configurations: config
            )
        } catch {
            fatalError("Failed to configure SwiftData: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: 700, minHeight: 400)
                .tint(selectedAccentColor)
        }
        .modelContainer(container)
        .defaultSize(width: 900, height: 600)
        .environment(updaterController)
        .commands {
            AppCommands(updaterController: updaterController)
        }

        Settings {
            SettingsView()
                .environment(updaterController)
        }
    }
}

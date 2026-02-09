import SwiftUI
import ServiceManagement

struct GeneralSettingsView: View {
    @Environment(UpdaterController.self) private var updaterController
    @State private var launchAtLogin = false

    var body: some View {
        @Bindable var updater = updaterController

        Form {
            Section("Startup") {
                Toggle("Launch at Login", isOn: $launchAtLogin)
                    .onChange(of: launchAtLogin) { _, newValue in
                        do {
                            if newValue {
                                try SMAppService.mainApp.register()
                            } else {
                                try SMAppService.mainApp.unregister()
                            }
                        } catch {
                            // Revert on failure
                            launchAtLogin = !newValue
                        }
                    }
            }

            Section("Updates") {
                Toggle(
                    "Check for updates automatically",
                    isOn: $updater.automaticallyChecksForUpdates
                )

                Button("Check for Updates Now...") {
                    updaterController.checkForUpdates()
                }
                .disabled(!updaterController.canCheckForUpdates)
            }
        }
        .formStyle(.grouped)
        .onAppear {
            launchAtLogin = SMAppService.mainApp.status == .enabled
        }
    }
}

import SwiftUI

struct AboutView: View {
    @Environment(UpdaterController.self) private var updaterController

    private var appVersion: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0"
    }

    private var buildNumber: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "1"
    }

    var body: some View {
        VStack(spacing: 16) {
            Spacer()

            Image(nsImage: NSApp.applicationIconImage)
                .resizable()
                .frame(width: 96, height: 96)

            Text("ShowTracker")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Version \(appVersion) (\(buildNumber))")
                .font(.caption)
                .foregroundStyle(.secondary)

            Button("Check for Updates...") {
                updaterController.checkForUpdates()
            }
            .disabled(!updaterController.canCheckForUpdates)

            HStack(spacing: 16) {
                Link("Website", destination: URL(string: "https://owldesign.github.io/ShowTracker")!)
                    .font(.caption)
                Link("GitHub", destination: URL(string: "https://github.com/owldesign/ShowTracker")!)
                    .font(.caption)
            }

            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
}

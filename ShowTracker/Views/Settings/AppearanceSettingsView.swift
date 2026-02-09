import SwiftUI

struct AppearanceSettingsView: View {
    @AppStorage("rowDensity") private var rowDensity: String = RowDensity.comfortable.rawValue
    @AppStorage("accentColor") private var accentColor: String = AppAccentColor.system.rawValue

    private var selectedDensity: RowDensity {
        RowDensity(rawValue: rowDensity) ?? .comfortable
    }

    private var selectedAccentColor: AppAccentColor {
        AppAccentColor(rawValue: accentColor) ?? .system
    }

    var body: some View {
        Form {
            Section("List Display") {
                Picker("Row Density", selection: $rowDensity) {
                    ForEach(RowDensity.allCases) { density in
                        Text(density.label).tag(density.rawValue)
                    }
                }
                .pickerStyle(.segmented)
            }

            Section("Accent Color") {
                Picker("Color", selection: $accentColor) {
                    ForEach(AppAccentColor.allCases) { color in
                        HStack(spacing: 8) {
                            if let c = color.color {
                                Circle()
                                    .fill(c)
                                    .frame(width: 12, height: 12)
                            } else {
                                Circle()
                                    .fill(.secondary)
                                    .frame(width: 12, height: 12)
                            }
                            Text(color.label)
                        }
                        .tag(color.rawValue)
                    }
                }
                .pickerStyle(.radioGroup)
            }
        }
        .formStyle(.grouped)
    }
}

#Preview {
    AppearanceSettingsView()
}

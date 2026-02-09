import SwiftUI
import SwiftData

struct AddEditSheet: View {
    let item: WatchItem?

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var title = ""
    @State private var type: WatchType = .show
    @State private var status: WatchStatus = .watching
    @State private var seasonNumber = 1
    @State private var episodeNumber = 1
    @State private var timestampHours = 0
    @State private var timestampMinutes = 0
    @State private var timestampSeconds = 0
    @State private var hasTimestamp = false
    @State private var notes = ""

    private var isEditing: Bool { item != nil }

    private var canSave: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        VStack(spacing: 0) {
            header
            Divider()
            formContent
            Divider()
            footer
        }
        .frame(width: 420, height: type == .show ? 380 : 420)
        .onAppear { populateFromItem() }
    }

    private var header: some View {
        HStack {
            Text(isEditing ? "Edit Item" : "Add Item")
                .font(.headline)
            Spacer()
            Button("Cancel") { dismiss() }
                .keyboardShortcut(.escape)
        }
        .padding()
    }

    private var formContent: some View {
        Form {
            TextField("Title", text: $title)

            if !isEditing {
                Picker("Type", selection: $type) {
                    ForEach(WatchType.allCases) { t in
                        Text(t.label).tag(t)
                    }
                }
                .pickerStyle(.segmented)
            }

            Picker("Status", selection: $status) {
                ForEach(WatchStatus.allCases) { s in
                    Text(s.label).tag(s)
                }
            }

            if type == .show {
                Stepper("Season: \(seasonNumber)", value: $seasonNumber, in: 1...99)
                Stepper("Episode: \(episodeNumber)", value: $episodeNumber, in: 1...999)
            } else {
                Toggle("Track timestamp", isOn: $hasTimestamp)
                if hasTimestamp {
                    HStack {
                        Stepper("H: \(timestampHours)", value: $timestampHours, in: 0...23)
                        Stepper("M: \(timestampMinutes)", value: $timestampMinutes, in: 0...59)
                        Stepper("S: \(timestampSeconds)", value: $timestampSeconds, in: 0...59)
                    }
                }
            }

            TextField("Notes (optional)", text: $notes, axis: .vertical)
                .lineLimit(3...6)
        }
        .formStyle(.grouped)
    }

    private var footer: some View {
        HStack {
            Spacer()
            Button(isEditing ? "Save" : "Add") {
                save()
                dismiss()
            }
            .keyboardShortcut(.return, modifiers: .command)
            .disabled(!canSave)
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }

    private func populateFromItem() {
        guard let item else { return }
        title = item.title
        type = item.type
        status = item.status
        seasonNumber = item.seasonNumber
        episodeNumber = item.episodeNumber
        notes = item.notes
        if let ts = item.timestampSeconds {
            hasTimestamp = true
            timestampHours = ts / 3600
            timestampMinutes = (ts % 3600) / 60
            timestampSeconds = ts % 60
        }
    }

    private func save() {
        let ts: Int? = hasTimestamp
            ? (timestampHours * 3600 + timestampMinutes * 60 + timestampSeconds)
            : nil

        if let item {
            item.title = title.trimmingCharacters(in: .whitespaces)
            item.status = status
            item.seasonNumber = seasonNumber
            item.episodeNumber = episodeNumber
            item.timestampSeconds = ts
            item.notes = notes
            item.lastUpdatedAt = Date.now
        } else {
            let newItem = WatchItem(
                title: title.trimmingCharacters(in: .whitespaces),
                type: type,
                status: status,
                seasonNumber: seasonNumber,
                episodeNumber: episodeNumber,
                timestampSeconds: ts,
                notes: notes
            )
            modelContext.insert(newItem)
            try? modelContext.save()
        }
    }
}

#Preview("Add") {
    AddEditSheet(item: nil)
        .modelContainer(previewContainer)
}

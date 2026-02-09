import SwiftData

@MainActor
let previewContainer: ModelContainer = {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: WatchItem.self, configurations: config)

    let breakingBad = WatchItem(title: "Breaking Bad", type: .show, seasonNumber: 3, episodeNumber: 7)
    let inception = WatchItem(title: "Inception", type: .movie, timestampSeconds: 4353, notes: "At the snow fortress scene")
    let theOffice = WatchItem(title: "The Office", type: .show, status: .finished, seasonNumber: 9, episodeNumber: 23)
    let severance = WatchItem(title: "Severance", type: .show, status: .watching, seasonNumber: 2, episodeNumber: 4, notes: "Just started season 2")
    let dune = WatchItem(title: "Dune: Part Two", type: .movie, status: .onHold, timestampSeconds: 2700)

    container.mainContext.insert(breakingBad)
    container.mainContext.insert(inception)
    container.mainContext.insert(theOffice)
    container.mainContext.insert(severance)
    container.mainContext.insert(dune)

    return container
}()

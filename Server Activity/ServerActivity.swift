import SwiftUI

@main struct ServerActivity: App {
    @StateObject private var monitor = ServerStatusMonitor()

    var body: some Scene {
        MenuBarExtra(
            "\(monitor.status?.players?.online ?? 0)/\(monitor.status?.players?.max ?? 0)",
            image: "steve-default"
        ) {
            NavigatedContent(displays: $monitor.playerDisplays)
        }.menuBarExtraStyle(.window)
    }
}

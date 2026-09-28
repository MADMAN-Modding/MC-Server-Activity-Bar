import SwiftUI

@main struct ServerActivity: App {
    @StateObject private var monitor = ServerStatusMonitor()

    var body: some Scene {
        MenuBarExtra(
            "\(monitor.status?.players?.online ?? 0)/\(monitor.status?.players?.max ?? 0)"
        ) {
            NavigatedContent(displays: $monitor.playerDisplays, monitor: monitor)
        }.menuBarExtraStyle(.window)
    }
}

//
//  ServerStatusMonitor.swift
//  Server Activity
//
//  Created by Mason Dehl on 9/26/26.
//

import Combine
import Foundation

class ServerStatusMonitor: ObservableObject {
    @Published var status: ServerStatus?
    private var timer: Timer?
    @Published var playerDisplays: [PlayerDisplay] = []

    init() {
        startPolling()
    }

    func startPolling() {
        var interval = UserDefaults.standard.integer(forKey: "pollingFrequency")
        
        print(interval)
        
        if (interval <= 0) {
            interval = 5
        }
        
        timer = Timer.scheduledTimer(withTimeInterval: TimeInterval(interval), repeats: true)
        { _ in
            Task { @MainActor in
                do {
                    // Get the server address from settings
                    let host =
                    UserDefaults.standard.string(forKey: "serverAddress")
                    ?? ""
                    guard !host.isEmpty else { return }
                    
                    let status = try await Networking.fetchServerStatus(
                        host: host
                    )
                    self.status = status
                    
                    let incomingPlayers = status.players?.sample ?? []
                    let currentUUIDs = Set(self.playerDisplays.map {$0.uuid} )
                    let incomingUUIDs = Set(incomingPlayers.map {$0.uuid} )
                    
                    let newUUIDs = incomingUUIDs.subtracting(currentUUIDs)
                    let departedUUIDs = currentUUIDs.subtracting(incomingUUIDs)
                    
                    // Remove players that have left
                    self.playerDisplays.removeAll { departedUUIDs.contains($0.uuid) }
                    
                    for player in incomingPlayers where newUUIDs.contains(player.uuid) {
                        let display = PlayerDisplay(uuid: player.uuid, username: player.name)
                        self.playerDisplays.append(display)
                        
                        Task {
                            await display.loadImage()
                        }
                    }
                } catch {
                    print("Error: \(error)")
                }
            }
        }

        timer?.fire()
    }
}

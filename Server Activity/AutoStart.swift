//
//  AutoStart.swift
//  Server Activity
//
//  Created by Mason Dehl on 9/28/26.
//

import ServiceManagement

func setLaunchAtLogin(_ enabled: Bool) {
    do {
        if enabled {
            try SMAppService.mainApp.register()
        } else {
            try SMAppService.mainApp.unregister()
        }
    } catch {
        print("Failed to \(enabled ? "enabled" : "disabled") launch at login: \(error)")
    }
}

var isLaunchAtLoginEnabled: Bool {
    SMAppService.mainApp.status == .enabled
}

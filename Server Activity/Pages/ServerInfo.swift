//
//  Info.swift
//  Server Activity
//
//  Created by Mason Dehl on 9/27/26.
//

import Playgrounds
import SwiftUI

struct ServerInfo: View {
    @Binding var displays: [PlayerDisplay]

    var body: some View {

        ScrollView {
            VStack {
                if displays.isEmpty {
                    Text("No Players Online")
                } else {
                    ForEach(displays) { display in
                        HStack {
                            display.image
                            Text(display.username)
                        }
                    }
                }
            }
        }
        .frame(maxHeight: 200)
        .fixedSize(horizontal: true, vertical: true)
    }
}

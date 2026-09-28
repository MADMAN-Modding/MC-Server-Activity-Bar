//
//  NavigatedContent.swift
//  Server Activity
//
//  Created by Mason Dehl on 9/27/26.
//
import SwiftUI
import AppKit

enum Page: String, CaseIterable {
    case info = "Info"
    case preferences = "Preferences"
}

struct NavigatedContent: View {
    @State private var selectedPage: Page = .info
    @Binding var displays: [PlayerDisplay]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Picker("", selection: $selectedPage) {
                    ForEach(Page.allCases, id: \.self) { page in
                        Text(page.rawValue).tag(page)
                    }
                }
                
                Button {
                    NSApplication.shared.terminate(nil)
                } label: {
                    Image(systemName: "xmark.circle")
                }
                .help("Quit")
            }
            .pickerStyle(.segmented)
            .labelsHidden()
            .padding(.horizontal, 8)
            .padding(.top, 8)

            Divider()
                .padding(.top, 8)

            Group {
                switch selectedPage {
                case .info:
                    ServerInfo(displays: $displays)
                case .preferences:
                    Preferences()
                }
            }
            .padding(8)
        }
    }
}

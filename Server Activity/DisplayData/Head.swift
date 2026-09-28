//
//  Head.swift
//  Server Activity
//
//  Created by Mason Dehl on 9/27/26.
//

import SwiftUI

class Head {
    var uuid: String
    var url: URL?
    
    init(uuid: String, size: Int) {
        self.uuid = uuid
        self.url = URL(string: "https://api.mcheads.org/head/\(self.uuid)/\(size)")
    }
    
    public func fetchImage() async -> Image {
        let fallbackImage = Image("steve-default")
        
        guard let url = url else { return fallbackImage }
        
        guard let data = try? await URLSession.shared.data(from: url) else { return fallbackImage }
        
        guard let nsImage: NSImage = NSImage(data: data.0) else { return fallbackImage }
        
        
        return Image(nsImage: nsImage)
    }
}

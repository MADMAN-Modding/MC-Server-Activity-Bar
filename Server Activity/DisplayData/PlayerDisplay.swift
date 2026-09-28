//
//  PlayerDisplay.swift
//  Server Activity
//
//  Created by Mason Dehl on 9/27/26.
//

import SwiftUI
import Combine

class PlayerDisplay: ObservableObject, Identifiable {
    let head: Head
    let uuid: String
    let username: String
    @Published var image: Image = Image("steve-default")
    
    init(uuid: String, username: String) {
        self.head = Head(uuid: uuid, size: Constants.headSize)
        self.uuid = uuid
        self.username = username
    }
    
    public func loadImage() async {
        self.image = await self.head.fetchImage()
    }
}

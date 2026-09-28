//
//  Poll.swift
//  Server Activity
//
//  Created by Mason Dehl on 9/26/26.
//

import Foundation

struct ServerStatus: Codable {
    let version: Version?
    let players: Players?
    let description: String?
    let favicon: String?
    
    struct Version: Codable {
        let protocolVersion: Int
        let name: String
        
        enum CodingKeys: String, CodingKey {
            case protocolVersion = "protocol"
            case name
        }
    }
    
    struct Players: Codable {
        let online: Int
        let max: Int
        let sample: [Player]?
        
        struct Player: Codable {
            let name: String
            let uuid: String
            
            enum CodingKeys: String, CodingKey {
                case name
                case uuid = "id"
            }
        }
    }
}

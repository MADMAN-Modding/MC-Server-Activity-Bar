//
//  Networking.swift
//  Server Activity
//
//  Created by Mason Dehl on 9/26/26.
//

import Foundation
import Network
import os

enum Networking {

    static func fetchServerStatus(host: String, port: UInt16 = 25565)
        async throws -> ServerStatus
    {
        let connection = try await openConnection(host: host, port: port)
        defer { connection.cancel() }

        let handshake = DataProcessing.buildHandshakePacket(
            address: host,
            port: port
        )
        try await send(handshake, over: connection)

        let statusRequest = DataProcessing.buildStatusRequestPacket()
        try await send(statusRequest, over: connection)

        let jsonString = try await readStatusResponse(from: connection)

        guard let jsonData = jsonString.data(using: .utf8) else {
            throw NetworkingError.invalidUTF8
        }

        return try JSONDecoder().decode(ServerStatus.self, from: jsonData)
    }

    static func openConnection(host: String, port: UInt16) async throws
        -> NWConnection
    {
        let connection = NWConnection(
            host: NWEndpoint.Host(host),
            port: NWEndpoint.Port(rawValue: port)!,
            using: .tcp
        )

        return try await withCheckedThrowingContinuation { continuation in
            let once = ResumeOnce()
            connection.stateUpdateHandler = { state in

                switch state {
                case .ready:
                    if once.claim() {
                        continuation.resume(returning: connection)
                    }
                case .failed(let error):
                    if once.claim() { continuation.resume(throwing: error) }
                case .cancelled:
                    if once.claim() {
                        continuation.resume(throwing: CancellationError())
                    }
                default:
                    break
                }
            }
            connection.start(queue: .main)
        }
    }

    static func send(_ bytes: [UInt8], over connection: NWConnection)
        async throws
    {
        let data = Data(bytes)
        try await withCheckedThrowingContinuation {
            (continuation: CheckedContinuation<Void, Error>) in
            connection.send(
                content: data,
                completion: .contentProcessed { error in
                    if let error = error {
                        continuation.resume(throwing: error)
                    } else {
                        continuation.resume(returning: ())
                    }
                }
            )
        }
    }

    static func receiveChunk(
        from connection: NWConnection,
        maxLength: Int = 4096
    ) async throws -> [UInt8] {
        try await withCheckedThrowingContinuation { continuation in
            connection.receive(
                minimumIncompleteLength: 1,
                maximumLength: maxLength
            ) { data, _, isComplete, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let data = data {
                    continuation.resume(returning: [UInt8](data))
                } else if isComplete {
                    continuation.resume(returning: [])
                } else {
                    continuation.resume(returning: [])
                }
            }
        }
    }

    static func readStatusResponse(from connection: NWConnection) async throws
        -> String
    {
        var buffer: [UInt8] = []

        // Keep reading until we can successfully decode the length VarInt
        // AND have that many bytes available after it.
        while true {
            let chunk = try await receiveChunk(from: connection)
            if chunk.isEmpty {
                throw NetworkingError.connectionClosedEarly
            }
            buffer += chunk

            if let (totalLength, lengthBytesRead) =
                try? DataProcessing.decodeVarInt(buffer, startingAt: 0)
            {
                let bytesNeeded = lengthBytesRead + Int(totalLength)
                if buffer.count >= bytesNeeded {
                    // Parse packet ID + JSON string length + JSON bytes.
                    var offset = lengthBytesRead
                    let (_, packetIdBytes) = try DataProcessing.decodeVarInt(
                        buffer,
                        startingAt: offset
                    )  // packet ID (0x00)
                    offset += packetIdBytes

                    let (jsonLength, jsonLengthBytes) =
                        try DataProcessing.decodeVarInt(
                            buffer,
                            startingAt: offset
                        )
                    offset += jsonLengthBytes

                    let jsonBytes = buffer[offset..<(offset + Int(jsonLength))]
                    guard
                        let jsonString = String(
                            bytes: jsonBytes,
                            encoding: .utf8
                        )
                    else {
                        throw NetworkingError.invalidUTF8
                    }
                    return jsonString
                }
            }
        }
    }

    enum NetworkingError: Error {
        case connectionClosedEarly
        case invalidUTF8
    }
}

private nonisolated final class ResumeOnce: Sendable {
    private let done = OSAllocatedUnfairLock(initialState: false)

    func claim() -> Bool {
        done.withLock { finished in
            if finished { return false }
            finished = true
            return true
        }
    }
}

//
//  DataProcessing.swift
//  Server Activity
//
//  Created by Mason Dehl on 9/26/26.
//

enum DataProcessing {
    static func encodeVarInt(_ value: Int32) -> [UInt8] {
        var value = UInt32(bitPattern: value)
        var bytes: [UInt8] = []

        repeat {
            var byte = UInt8(value & 0x7F)
            value >>= 7
            if value != 0 {
                byte |= 0x80
            }
            bytes.append(byte)
        } while value != 0

        return bytes
    }

    enum VarIntError: Error {
        case tooLong
    }

    static func decodeVarInt(_ bytes: [UInt8], startingAt offset: Int) throws
        -> (value: Int32, bytesRead: Int)
    {
        var numRead = 0
        var result: Int32 = 0

        while true {
            guard numRead < 5 else { throw VarIntError.tooLong }  // VarInts are max 5 bytes for a 32-bit int

            let byte = bytes[offset + numRead]
            let valuePart = Int32(byte & 0x7F)
            result |= (valuePart << (7 * numRead))

            numRead += 1

            if (byte & 0x80) == 0 {
                break  // top bit unset means this was the last byte
            }
        }

        return (result, numRead)
    }

    //    Used for encoding strings with their length to the format Minecraft uses
    static func encodeString(_ string: String) -> [UInt8] {
        let utf8Bytes = Array(string.utf8)
        let lengthPrefix = encodeVarInt(Int32(utf8Bytes.count))
        return lengthPrefix + utf8Bytes
    }

    static func encodeUnsignedShort(_ value: UInt16) -> [UInt8] {
        return [UInt8(value >> 8), UInt8(value & 0xFF)]
    }

    static func buildStatusRequestPacket() -> [UInt8] {
        let payload = encodeVarInt(0x00)  // packet ID only
        let length = encodeVarInt(Int32(payload.count))
        return length + payload
    }

    // Builds the handshake packet, protocolVersion agnostic unless specified
    static func buildHandshakePacket(
        address: String,
        port: UInt16,
        protocolVersion: Int32 = -1
    ) -> [UInt8] {
        var payload: [UInt8] = []
        payload += encodeVarInt(0x00)  // Pakcet ID
        payload += encodeVarInt(protocolVersion)  // Protocol Version
        payload += encodeString(address)  // Server Address
        payload += encodeUnsignedShort(port)  // Server Port for Connections
        payload += encodeVarInt(1)  // next state is status

        let length = encodeVarInt(Int32(payload.count))
        return length + payload
    }

}

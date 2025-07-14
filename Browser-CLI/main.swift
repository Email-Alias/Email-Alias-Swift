//
//  main.swift
//  Browser-CLI
//
//  Created by Sven on 18.06.25.
//

import SwiftData
import Foundation

private func littleEndianUInt32(from bytes: [UInt8]) -> UInt32 {
    return UInt32(bytes[0])
         | (UInt32(bytes[1]) << 8)
         | (UInt32(bytes[2]) << 16)
         | (UInt32(bytes[3]) << 24)
}

private func bytesFromLittleEndian(_ length: UInt32) -> [UInt8] {
    let le = length.littleEndian
    return [
        UInt8(truncatingIfNeeded: le >>  0),
        UInt8(truncatingIfNeeded: le >>  8),
        UInt8(truncatingIfNeeded: le >> 16),
        UInt8(truncatingIfNeeded: le >> 24)
    ]
}

private func readMessageData() -> [String: String]? {
    let stdin = FileHandle.standardInput

    let lenBytes = stdin.readData(ofLength: 4)
    guard lenBytes.count == 4 else {
        return nil
    }
    let length = littleEndianUInt32(from: Array(lenBytes))
    let data = stdin.readData(ofLength: Int(length))
    return try? JSONSerialization.jsonObject(with: data, options: []) as? [String: String]
}

private func sendMessageData(_ data: [String: Any]) {
    if let jsonData = try? JSONSerialization.data(withJSONObject: data, options: []) {
        let stdout = FileHandle.standardOutput
        
        let lengthBytes = bytesFromLittleEndian(UInt32(jsonData.count))
        stdout.write(Data(lengthBytes))
        
        stdout.write(jsonData)
        stdout.synchronizeFile()
    }
}

let messageData = readMessageData()
switch messageData?["type"] {
case "getAliases":
    if let aliases = getAliases() {
        sendMessageData(aliases)
    }
default:
    break
}

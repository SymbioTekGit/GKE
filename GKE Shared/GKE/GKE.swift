//
//  GKE.swift
//  GKE
//
//  Created by Alvin Heib on 16/11/2024.
//

import Foundation

struct GKEPos: Codable {
    var x: Float32
    var y: Float32
}

struct GKECoord: Codable {
    var col: UInt16
    var row: UInt16
    
    static let zero = GKECoord(col: 0, row: 0)
}

struct GKESize: Codable {
    var width: UInt16
    var height: UInt16
}

class GKEString: Codable {
    var bytes: [UInt8] = []
    
    init(_ str: String) {
        for char in str {
            bytes.append(char.asciiValue!)
        }
    }
    
    func substring(start: Int, end: Int) -> String {
        return String(bytes: bytes[start...end], encoding: .utf8)!
    }
}

struct GKEColor: Codable {
    var bytes: [UInt8] = [0x00, 0x00, 0x00, 0x00]
    
    // Compute variables
    var red: UInt8      {    get { return bytes[0] }     set { bytes[0] = newValue } }
    var green: UInt8    {    get { return bytes[1] }     set { bytes[1] = newValue } }
    var blue: UInt8     {    get { return bytes[2] }     set { bytes[2] = newValue } }
    var alpha: UInt8    {    get { return bytes[3] }     set { bytes[3] = newValue } }
    
    init(red: UInt8, green: UInt8, blue: UInt8, alpha: UInt8) {
        self.bytes = [red, green, blue, alpha]
    }
    
    init(_ hexstring: String) {
        let string = GKEString(hexstring)
        self.bytes = [
            UInt8(string.substring(start: 0, end: 1), radix: 16)!,
            UInt8(string.substring(start: 2, end: 3), radix: 16)!,
            UInt8(string.substring(start: 4, end: 5), radix: 16)!,
            UInt8(string.substring(start: 6, end: 7), radix: 16)!]
    }
    
    static let black = GKEColor("000000FF")
    static let white = GKEColor("FFFFFFFF")
    static let red = GKEColor("FF0000FF")
    static let green = GKEColor("00FF00FF")
    static let blue = GKEColor("0000FFFF")
    static let purple = GKEColor("FF00FFFF")
    static let yellow = GKEColor("FFFF00FF")
    static let cyan = GKEColor("00FFFFFF")
    static let lightgray = GKEColor("C0C0C0FF")
    static let gray = GKEColor("808080")
    static let darkgray = GKEColor("404040")
}


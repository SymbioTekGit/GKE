//
//  GKEMetaTileNode.swift
//  GKE
//
//  Created by Alvin Heib on 03/11/2024.
//

import GameplayKit

struct GKETileDef: Codable {
    var dx: Int
    var dy: Int
    var dg: Int
}
    
class GKEMetaTile: NSObject {
    var col: Int
    var row: Int
    var tiles: [GKETileDef]
    var tilelayer: GKETileLayer
    
    init(col: Int, row: Int, tiles: [GKETileDef], tilelayer: GKETileLayer) {
        self.col = col
        self.row = row
        self.tiles = tiles
        self.tilelayer = tilelayer
        super.init()
    }
    
    func draw(offset: GKECoord = .zero) {
        for id in 0...tiles.count-1 {
            tilelayer.update(col: col + tiles[id].dx + offset.col, row: row + tiles[id].dy + offset.row, gid: tiles[id].dg)
        }
    }
    
    func clear(offset: GKECoord = .zero) {
        for id in 0...tiles.count-1 {
            tilelayer.update(col: col + tiles[id].dx, row: row + tiles[id].dy, gid: 0)
        }
    }
    
    func update(tiles: [GKETileDef], offset: GKECoord = .zero) {
        clear(offset: offset)
        
        self.tiles = tiles
        draw(offset: offset)
    }
    
    func move(col: Int, row: Int, offset: GKECoord = .zero) {
        clear(offset: offset)
        self.col = col
        self.row = row
        draw(offset: offset)
    }
}

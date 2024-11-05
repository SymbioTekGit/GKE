//
//  GKETileLayer.swift
//  GKE
//
//  Created by Alvin Heib on 03/11/2024.
//

import GameplayKit

class GKETileLayer: NSObject {
    var cols: Int
    var rows: Int
    var tiles: [[Int]]
    var tileset: GKETileSet
    var node: SKNode
    
    init(name: String, cols: Int, rows: Int, tileset: GKETileSet) {
        self.cols = cols
        self.rows = rows
        self.tileset = tileset
        self.tiles = Array(repeating: Array(repeating: 0, count:cols), count:rows)
        self.node = SKNode()
        super.init()
        
        node.name = name
    }
    
    func addNode(col: Int, row: Int, gid: Int) {
        let tile = GKETileNode(col: col, row: row, gid: gid, tileset: tileset)
        node.addChild(tile)
    }
    
    func getNode(col: Int, row: Int) -> GKETileNode? {
        let tile = node.atPoint(CGPoint(x: col * tileset.tilewidth + tileset.tilewidth / 2, y: row * tileset.tileheight + tileset.tileheight / 2))
        if tile.parent == node {
            return tile as? GKETileNode
        }
        return nil
    }
    
    func set(col: Int, row: Int, gid: Int) {
        if (col < 0) || (col >= cols) || (row < 0) || (row >= rows) {
            return
        }
        tiles[row][col] = gid
        addNode(col: col, row: row, gid: gid)
    }
    
    func get(col: Int, row: Int) -> Int {
        if (col < 0) || (col >= cols) || (row < 0) || (row >= rows) {
            return 0
        }

        return tiles[row][col]
    }
    
    func rem(col: Int, row: Int) {
        if (col < 0) || (col >= cols) || (row < 0) || (row >= rows) {
            return
        }

        if let tile = getNode(col: col, row: row) {
            tile.removeFromParent()
        }
        tiles[row][col] = 0
    }
    
    func update(col: Int, row: Int, gid: Int) {
        if gid == 0 {
            rem(col: col, row: row)
            return
        }
        
        if let tile = getNode(col: col, row: row) {
            tile.update(gid: gid)
        } else {
            addNode(col: col, row: row, gid: gid)
        }
        tiles[row][col] = gid
    }
}

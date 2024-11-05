//
//  GKETileNode.swift
//  GKE
//
//  Created by Alvin Heib on 03/11/2024.
//

import GameplayKit

struct GKECoord {
    var col: Int
    var row: Int
    
    static let zero = GKECoord(col: 0, row: 0)
}

class GKETileNode: SKSpriteNode {
    var col: Int = 0
    var row: Int = 0
    var gid: Int = 1
    var tileset: GKETileSet
    
    init(col: Int, row: Int, gid: Int, tileset: GKETileSet) {
        self.tileset = tileset
        let tex = SKTexture(cgImage: tileset[gid])
        tex.filteringMode = .nearest
        super.init(texture: tex, color: .red, size: tex.size())
        
        self.name = "\(gid)"
        self.anchorPoint = .zero
        
        move(col: col, row: row)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func move(col: Int, row: Int) {
        self.col = col
        self.row = row
        self.position = CGPoint(x: col * tileset.tilewidth, y: row * tileset.tileheight)
    }
    
    func update(gid: Int) {
        let tex = SKTexture(cgImage: tileset[gid])
        tex.filteringMode = .nearest
        
        self.texture = tex
        self.size = tileset.cgSize
    }
}

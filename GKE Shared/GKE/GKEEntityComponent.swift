//
//  GKEEntityComponent.swift
//  GKE
//
//  Created by Alvin Heib on 10/11/2024.
//

import GameplayKit

class GKEEntity: GKEntity {
    var type: Int
    var variant: Int
    
    init(type: Int, variant: Int) {
        self.type = type
        self.variant = variant
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class GKETileVisualComponent: GKSKNodeComponent {
    var col: Int
    var row: Int
    var gid: Int
    var tileset: GKETileSet
    
    init(col: Int, row: Int, gid: Int, tileset: GKETileSet) {
        self.col = col
        self.row = row
        self.gid = gid
        self.tileset = tileset
        let tile = GKETileNode(col: col, row: row, gid: gid, tileset: tileset)
        super.init(node: tile)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func move(col: Int, row: Int) {
        guard let tile = node as? GKETileNode else {
            return
        }
        tile.move(col: col, row: row)
    }
    /*
    override func agentDidUpdate(_ agent: GKAgent) {
        guard let agent = agent as? GKAgent2D else {
            return
        }
        guard let tile = node as? GKETileNode else {
            return
        }
        
        let col = Int(agent.position.x / Float(tileset.tilewidth))
        let row = Int(agent.position.x / Float(tileset.tilewidth))
        tile.move(col: col, row: row)
    }
     */
}

class GKEHitComponent: GKComponent {
    var hits: Int
    
    init(hits: Int) {
        self.hits = hits
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}



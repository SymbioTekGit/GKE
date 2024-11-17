//
//  BoulderDashCave.swift
//  GKE
//
//  Created by Alvin Heib on 17/11/2024.
//

import GameplayKit

class BoulderDashCave: GKEntity {
    var scene: BoulderDashGameScene
    var entities = [BoulderDashEntity]()
    
    init(scene: BoulderDashGameScene) {
        self.scene = scene
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func animate() {
        for entity in entities {
            if entity.isAnimated {
                animate(entity: entity)
            }
        }
    }
    
    func isFallingCompleted() -> Bool {
        var isFallingCompleted = true
        entities.sort()
        
        for entity in entities {
            if entity.isFallable == false {
                continue
            }
            
            if let below = find(col: entity.col, row: entity.row - 1) {
                if below.isExplodable && entity.isFalling {
                    // TBD: explode...
                } else {
                    if below.isRounded {
                        let left = find(col: entity.col - 1, row: entity.row)
                        let bottomleft = find(col: entity.col - 1, row: entity.row - 1)
                        if (left == nil) && (bottomleft == nil) {
                            // fall left
                            move(entity: entity, dx: -1, dy: 0)
                            entity.isFalling = true
                            isFallingCompleted = false
                        } else {
                            let right = find(col: entity.col + 1, row: entity.row)
                            let bottomright = find(col: entity.col + 1, row: entity.row - 1)
                            if (right == nil) && (bottomright == nil) {
                                // fall right
                                move(entity: entity, dx: 1, dy: 0)
                                entity.isFalling = true
                                isFallingCompleted = false
                            } else {
                                // stop falling
                                entity.isFalling = false
                            }
                        }
                    } else {
                        // stop falling
                        entity.isFalling = false
                    }
                }
            } else {
                // no one below... can fall
                move(entity: entity, dx: 0, dy: -1)
                entity.isFalling = true
                isFallingCompleted = false
            }
        }
        
        return isFallingCompleted
    }
    
    func reset(datas: [[Int]]) {
        let rows = datas.count
        let cols = datas[0].count
        for row in 0...rows-1 {
            for col in 0...cols-1 {
                let obj = datas[row][col]
                if obj == 0x00 {
                    continue
                }
                add(col: col, row: row, type: BoulderDashType(rawValue: obj)!)
            }
        }
    }
    
    func find(col: Int, row: Int) -> BoulderDashEntity? {
        return entities.first(where: { ($0.row == row) && ($0.col == col) })
    }
    
    func find(type: BoulderDashType) -> BoulderDashEntity? {
        return entities.first(where: { $0.type == type })
    }
    
    func add(col: Int, row: Int, type: BoulderDashType) {
        let entity = BoulderDashEntity(col: col, row: row, type: type)
        entities.append(entity)
        scene.tilelayers[0].update(col: col, row: row, gid: entity.anims[entity.animId])
    }
    
    func update(col: Int, row: Int, type: BoulderDashType) {
        if let entity = find(col: col, row: row) {
            entity.update(type: type)
            scene.tilelayers[0].update(col: entity.col, row: entity.row, gid: entity.gid)
        }
    }
    
    func move(entity: BoulderDashEntity, dx: Int, dy: Int) {
        scene.tilelayers[0].update(col: entity.col, row: entity.row, gid: 0)
        entity.move(dx: dx, dy: dy)
        scene.tilelayers[0].update(col: entity.col, row: entity.row, gid: entity.gid)
    }
    
    func animate(entity: BoulderDashEntity) {
        entity.animate()
        scene.tilelayers[0].update(col: entity.col, row: entity.row, gid: entity.gid)
    }
}

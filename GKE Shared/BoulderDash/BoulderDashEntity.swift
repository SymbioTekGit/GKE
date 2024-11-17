//
//  BoulderDashEntity.swift
//  GKE
//
//  Created by Alvin Heib on 17/11/2024.
//

import GameplayKit

enum BoulderDashType: Int {
    case space              = 0x00
    case dirt               = 0x01
    case brickWall          = 0x02
    case magicWall          = 0x03
    case preOutbox          = 0x04
    case outbox             = 0x05
    case steelWall          = 0x07
    case firefly            = 0x08
    case boulder            = 0x10
    case diamond            = 0x14
    case explodeToSpace     = 0x1B
    case explodeToDiamond   = 0x20
    case preRockford        = 0x25
    case butterfly          = 0x30
    case rockford           = 0x38
    case amoeba             = 0x3A
}

class BoulderDashEntity: GKEntity, Comparable {
    var col: Int
    var row: Int
    var type: BoulderDashType
    var gid: Int
    var anims: [Int]
    var animId: Int
    
    var isFallable = false
    var isFalling = false
    var isRounded = false
    var isAnimated = false
    var isExplodable = false
    var isConsumable = true
    
    let animsList: [BoulderDashType: [Int]] = [ .space: [0], .dirt: [28], .brickWall: [31], .magicWall: [32], .preOutbox: [30], .outbox: [30], .steelWall: [30], .firefly: [15, 16], .boulder: [29], .diamond: [11, 12, 13, 14], .explodeToSpace: [21, 22, 23, 24], .explodeToDiamond: [25, 26, 27, 11], .preRockford: [30], .butterfly: [17, 18], .rockford: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10], .amoeba: [19, 20]]
    
    init(col: Int, row: Int, type: BoulderDashType) {
        self.col = col
        self.row = row
        self.type = type
        self.anims = animsList[type]!
        self.animId = 0
        self.gid = anims[animId]
        super.init()
        
        if (type == .diamond) || (type == .boulder) {
            isFallable = true
        }
        
        if (type == .brickWall) || (type == .boulder) || (type == .diamond) {
            isRounded = true
        }
        if (type == .firefly) || (type == .butterfly) || (type == .rockford) {
            isExplodable = true
        }
        if (type == .preOutbox) || (type == .outbox) || (type == .steelWall) || (type == .explodeToSpace) || (type == .explodeToDiamond) || (type == .preRockford) {
            isConsumable = false
        }
        if (type == .diamond) {
            isAnimated = true
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    static func < (_ left: BoulderDashEntity, _ right: BoulderDashEntity) -> Bool {
       return left.row < right.row || (left.row == right.row && left.col < right.col)
    }
    
    func update(type: BoulderDashType) {
        self.anims = animsList[type]!
        self.animId = 0
        self.gid = anims[animId]
    }
    
    func move(dx: Int, dy: Int) {
        self.col += dx
        self.row += dy
    }
    
    func animate() {
        animId += 1
        if animId >= anims.count {
            animId = 0
        }
        gid = anims[animId]
    }
    
}

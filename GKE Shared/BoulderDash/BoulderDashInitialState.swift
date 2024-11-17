//
//  BoulderDashInitialState.swift
//  GKE
//
//  Created by Alvin Heib on 17/11/2024.
//

import GameplayKit

class BoulderDashInitialState: GKState {
    var scene: BoulderDashGameScene
    
    init(_ scene: BoulderDashGameScene) {
        self.scene = scene
        super.init()
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        if stateClass == BoulderDashRunState.self {
            return true
        }
        
        return false
    }
    
    override func didEnter(from previousState: GKState?) {
        scene.tilesets = [ GKETileSet(imagenamed: "boulder-dash-arcade-tileset", tilewidth: 16, tileheight: 16, tilecount: 37) ]
        scene.tilelayers = [ GKETileLayer(name: "gamelayer", cols: 40, rows: 22, tileset: scene.tilesets[0])]
        scene.tilelayers[0].node.position = .zero
        scene.addChild(scene.tilelayers[0].node)
        
        scene.cave = BoulderDashCave(scene: scene)
        
        let datas = load(caveId: scene.caveId, difficultyId: scene.difficultyId)
        scene.cave.reset(datas: datas)
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        scene.cave.animate()
        
        if scene.cave.isFallingCompleted() == true {
            stateMachine!.enter(BoulderDashRunState.self)
        }
    }
    
    func load(caveId: Int, difficultyId: Int) -> [[Int]] {
        let rawdatas = [
            "01 14 0A 0F 0A 0B 0C 0D 0E 0C 0C 0C 0C 0C 96 6E 46 28 1E 08 0B 09 D4 20 00 10 14 00 3C 32 09 00 42 01 09 1E 02 42 09 10 1E 02 25 03 04 04 26 12 FF" ]
        let bytes = rawdatas[caveId - 1].components(separatedBy: " ").map( { Int($0, radix: 16)! })
        
        let cols = 40
        let rows = 22
        var datas = Array(repeating: Array(repeating: 0x01, count: cols), count: rows)
        let random = GKARC4RandomSource(seed: Data([UInt8(bytes[0x04 + difficultyId])]))
        
        for row in 0...rows-1 {
            for col in 0...cols-1 {
                if (col == 0) || (col == cols-1) || (row == 0) || (row == rows-1) {
                    datas[row][col] = 0x07         // steelWall
                    continue
                }
                
                let proba = random.nextInt(upperBound: 256)
                if proba < bytes[0x1C] {
                    datas[row][col] = bytes[0x18]
                } else if proba < bytes[0x1C] + bytes[0x1D] {
                    datas[row][col] =  bytes[0x19]
                } else if proba < bytes[0x1C] + bytes[0x1D] + bytes[0x1E] {
                    datas[row][col] =  bytes[0x1A]
                } else if proba < bytes[0x1C] + bytes[0x1D] + bytes[0x1E] + bytes[0x1F] {
                    datas[row][col] =  bytes[0x1B]
                }
            }
        }
        
        var addr = 0x20
        while bytes[addr] != 0xFF {
            let obj = bytes[addr] & 0b00111111
            let col = bytes[addr + 1]
            let row = rows - (bytes[addr + 2] - 2) - 1
            switch (bytes[addr] & 0b11000000) >> 6 {
            case 0:         // store single object
                datas[row][col] = obj
                addr += 3
                break
            case 1:         // draw a line of that object
                let len = bytes[addr + 3]
                var dx = 0
                var dy = 0
                switch bytes[addr + 4] {
                case 0:     dy = 1;             break
                case 1:     dx = 1; dy = 1;     break
                case 2:     dx = 1;             break
                case 3:     dx = 1; dy = -1;    break
                case 4:     dy = -1;            break
                case 5:     dx = -1; dy = -1;   break
                case 6:     dx = -1;            break
                case 7:     dx = -1; dy = 1;    break
                default:    break
                }
                for id in 0...len-1 {
                    datas[row + dy * id][col + dx * id] = obj
                }
                addr += 5
                break
            case 2:         // draw a rectangle of that object, filled with a second object
                print("ERROR: case 2 not yet implemented")
                addr += 6
                break
            case 3:         // draw a rectangle of that object, don't modify the insides.
                print("ERROR: case 3 not yet implemented")
                addr += 6-5
                break
            default:
                break
            }
        }
        
        return datas
    }
}

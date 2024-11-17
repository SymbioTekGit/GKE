//
//  GauntletGameScene.swift
//  GKE
//
//  Created by Alvin Heib on 16/11/2024.
//

import GameplayKit

class GauntletGameScene: SKScene {
    var entities = [GKEntity]()
    var deltaTime = TimeInterval()
    var previousTime = TimeInterval()
    
    class func newGameScene() -> GauntletGameScene {
        // Load 'GauntletGameScene.sks' as an SKScene.
        guard let scene = SKScene(fileNamed: "GauntletGameScene") as? GauntletGameScene else {
            print("Failed to load GauntletGameScene.sks")
            abort()
        }
        
        // Set the scale mode to scale to fit the window
        scene.scaleMode = .aspectFit
        
        return scene
    }
    
    
    override func didMove(to view: SKView) {
        load(stageId: 1)
    }
    
    func load(stageId: Int) {
        let tilewidth = 16
        let tileheight = 16
        
        let rawdatas = [
            ["####################",
             "#       #         G#",
             "#       #          #",
             "#  P    *          #",
             "#       *          #",
             "#       #          #",
             "#       #########  #",
             "#       #          #",
             "#       #          #",
             "#       #          #",
             "#I      #X         #",
             "####################"]]
        
        let datas = rawdatas[stageId - 1]
        let rows = datas.count
        for row in 0...rows-1 {
            var col = 0
            for char in datas[rows - row - 1] {
                let types: [Character: GauntletType] = [ " ": .none, "X": .exit, "#": .wall, "*": .door, "G": .generator, "P": .player, "E": .ennemy, "I": .item]
                let entity = GauntletEntity(origin: CGPoint(x: col * tilewidth, y: row * tileheight), size: CGSize(width: tilewidth, height: tileheight), type: types[char]!)
                entities.append(entity)
                addChild(entity.visual.node)
                
                col += 1
            }
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        deltaTime = currentTime - previousTime
        
        for entity in entities {
            entity.update(deltaTime: deltaTime)
        }
        
        previousTime = currentTime
    }
}

enum GauntletType: UInt32 {
    case none
    case exit
    case wall
    case door
    case generator
    case player
    case ennemy
    case item
    
    var color: SKColor {
        switch self {
        case .exit:         return .green
        case .wall:         return .darkGray
        case .door:         return .cyan
        case .generator:    return .red
        case .player:       return .blue
        case .ennemy:       return .systemPink
        case .item:         return .yellow
        default:            return .white
        }
    }
}
/*
enum GauntletGeneratorVariant: Int {
    case bone       = 1
    case block
}

enum GauntletPlayerVariant: Int {
    case thor       = 1
    case valkyrie
    case wizard
    case elf
}

enum GauntletEnnemyVariant: Int {
    case ghost
    case grunt
    case demon
    case sorcerer
    case lobber
    case death
    case thief
}

enum GauntletItemVariant: Int {
    case exit           = 1
    case wall
    case breakableWall
    case teleporter
    case door
    case key
    case potion
    case treasure
    case jewel
    case food
    case trap
    case invisibility
    case upgrade
}
*/
class GauntletEntity: GKEntity {
    var origin: CGPoint
    var size: CGSize
    var type: GauntletType
    var visual: GauntletVisualComponent
    
    init(origin: CGPoint, size: CGSize, type: GauntletType) {
        self.origin = origin
        self.size = size
        self.type = type
        self.visual = GauntletVisualComponent(origin: origin, size: size, type: type)
        super.init()
        
        addComponent(GKSKNodeComponent(node: visual.node))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class GauntletVisualComponent: GKSKNodeComponent {
    init(origin: CGPoint, size: CGSize, type: GauntletType) {
        let node = SKShapeNode(rect: CGRect(origin: origin, size: size))
        node.fillColor = type.color
        super.init(node: node)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

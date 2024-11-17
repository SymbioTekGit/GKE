//
//  ArkanoidGameScene.swift
//  GKE
//
//  Created by Alvin Heib on 09/11/2024.
//

import GameplayKit

class ArkanoidGameScene: SKScene, SKPhysicsContactDelegate {
    var stageId = 1
    var bricks = [ArkanoidBrickNode]()
    var vauses = [ArkanoidVausNode]()
    var balls = [ArkanoidBallNode]()
    var walls = [ArkanoidWallNode]()
    
    class func newGameScene() -> ArkanoidGameScene {
        // Load 'ArkanoidGameScene.sks' as an SKScene.
        guard let scene = SKScene(fileNamed: "ArkanoidGameScene") as? ArkanoidGameScene else {
            print("Failed to load ArkanoidGameScene.sks")
            abort()
        }
        
        // Set the scale mode to scale to fit the window
        scene.scaleMode = .aspectFit
        
        return scene
    }
    
    override func didMove(to view: SKView) {
        load(stageId: stageId)
        physicsWorld.contactDelegate = self
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        var bodyA = contact.bodyA
        var bodyB = contact.bodyB
        if bodyA.categoryBitMask > bodyB.categoryBitMask {
            let temp = bodyA
            bodyA = bodyB
            bodyB = temp
        }
        print("CONTACT: \(contact.bodyA.categoryBitMask) and \(contact.bodyB.categoryBitMask)")
        print(bodyA.velocity)
    }
    
    func load(stageId: Int) {
        self.removeAllChildren()
        
        let levelRawDatas = [ [
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9,
            5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5,
            8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8,
            6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6,
            7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7,
            4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4] ]
        
        let cols = 13
        let rows = 29
        var id = 0
        while id < levelRawDatas[0].count {
            let code = levelRawDatas[0][id]
            if code != 0 {
                let col = id % cols
                let row = rows - Int(id / cols) - 1
                
                let node = ArkanoidBrickNode(col: col, row: row, type: ArkanoidBrickType(rawValue: code)!)
                bricks.append(node)
                self.addChild(node)
            }
            id += 1
        }
        
        let vaus = ArkanoidVausNode(type: .standard)
        vauses.append(vaus)
        self.addChild(vaus)
        
        let ball = ArkanoidBallNode()
        balls.append(ball)
        self.addChild(ball)
    
        var x = 8
        for id in 0...5 {
            let leftwall = ArkanoidWallNode(pos: CGPoint(x: 4, y: 40 * id + 20), type: (id == 5 ? .vertical1 : .vertical3))
            walls.append(leftwall)
            self.addChild(leftwall)
            
            let rightwall = ArkanoidWallNode(pos: CGPoint(x: 220, y: 40 * id + 20), type: (id == 5 ? .vertical2 : .vertical3))
            walls.append(rightwall)
            self.addChild(rightwall)

            switch id {
            case 0, 4:
                let topWall = ArkanoidWallNode(pos: CGPoint(x: x + 16, y: 236), type: .horizontal1)
                walls.append(topWall)
                self.addChild(topWall)
                x += 32
                break
            case 1, 3:
                let topWall = ArkanoidWallNode(pos: CGPoint(x: x + 16, y: 236), type: .horizontal3)
                walls.append(topWall)
                self.addChild(topWall)
                x += 32
                break
            case 2:
                let topWall = ArkanoidWallNode(pos: CGPoint(x: x + 40, y: 236), type: .horizontal2)
                walls.append(topWall)
                self.addChild(topWall)
                x += 80
                break
            default:
                break
            }
        }
    }
    
    
}

#if os(iOS) || os(tvOS)
// Touch-based event handling
extension ArkanoidGameScene {

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
   
}
#endif

#if os(OSX)
// Mouse-based event handling
extension ArkanoidGameScene {

    override func mouseDown(with event: NSEvent) {
        
    }
    
    override func mouseDragged(with event: NSEvent) {
        let location = event.location(in: self)
        for vaus in vauses {
            var pos = location.x
            if pos < vaus.size.width / 2 + 8 {
                pos = vaus.size.width / 2 + 8
            } else if pos > (224 - 8) - vaus.size.width / 2 {
                pos = (224 - 8) - vaus.size.width / 2
            }
            let delta = pos - vaus.position.x
            vaus.position.x += delta
            
            for ball in balls {
                if ball.isSticked {
                    ball.position.x += delta
                }
            }
        }
    }
    
    override func mouseUp(with event: NSEvent) {
        for ball in balls {
            if ball.isSticked {
                ball.physicsBody?.applyImpulse(CGVector(dx: 100, dy: 100))
                ball.isSticked = false
                print(ball.physicsBody!.velocity)
            }
        }
    }
}
#endif

enum ArkanoidType: UInt32 {
    case ball           = 1     // 1 >> 1
    case wall           = 2     // 1 >> 2
    case vaus           = 4     // 1 >> 3
    case powerup        = 8     // 1 >> 4
    case brick          = 16    // 1 >> 5
    case ennemy         = 32    // 1 >> 6
}

enum ArkanoidBrickType: Int {
    case white           = 1
    case orange
    case cyan
    case green
    case red
    case blue
    case magenta
    case yellow
    case silver
    case gold
}

enum ArkanoidVausType {
    case standard
    case laser
    case size
    case magnetic
    case slow
    case warping
    case trail
    case split
}

enum ArkanoidWallType: Int {
    case horizontal1    = 1
    case horizontal2
    case horizontal3
    case vertical1
    case vertical2
    case vertical3
}

class ArkanoidBrickNode: SKSpriteNode {
    let atlas = SKTextureAtlas(named: "arkanoid-arcade")
    var type: ArkanoidBrickType
    var animId = 1
    
    init(col: Int, row: Int, type: ArkanoidBrickType) {
        self.type = type
        let tex = atlas.textureNamed("bricks-\(type)-\(animId)")
        tex.filteringMode = .nearest
        super.init(texture: tex, color: .red, size: tex.size())
        
        name = "bricks-\(type)"
        position = CGPoint(x: col * 16 + 16, y: row * 8 + 4)
        
        let body = SKPhysicsBody(rectangleOf: CGSize(width: 16, height: 8))
        body.mass = 1
        body.isDynamic = false
        body.allowsRotation = false
        body.affectedByGravity = false
        body.restitution = 0.0
        body.friction = 0.0
        body.categoryBitMask = ArkanoidType.brick.rawValue
        body.collisionBitMask = ArkanoidType.ball.rawValue | ArkanoidType.ennemy.rawValue
        body.contactTestBitMask = ArkanoidType.ball.rawValue | ArkanoidType.ennemy.rawValue
        self.physicsBody = body
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class ArkanoidVausNode: SKSpriteNode {
    let atlas = SKTextureAtlas(named: "arkanoid-arcade")
    var type: ArkanoidVausType
    var animId = 1
    
    init(type: ArkanoidVausType) {
        self.type = type
        let tex = atlas.textureNamed("vaus-\(type)-\(animId)")
        tex.filteringMode = .nearest
        super.init(texture: tex, color: .red, size: tex.size())
        
        name = "vaus-\(type)"
        position = CGPoint(x: 224 / 2, y: 12)
        
        let body = SKPhysicsBody(rectangleOf: CGSize(width: 32, height: 8))
        body.mass = 1
        body.isDynamic = false
        body.allowsRotation = false
        body.affectedByGravity = false
        body.restitution = 0.0
        body.friction = 0.0
        body.categoryBitMask = ArkanoidType.vaus.rawValue
        body.collisionBitMask = ArkanoidType.ball.rawValue | ArkanoidType.ennemy.rawValue
        body.contactTestBitMask = ArkanoidType.ball.rawValue | ArkanoidType.ennemy.rawValue
        self.physicsBody = body
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class ArkanoidBallNode: SKSpriteNode {
    let atlas = SKTextureAtlas(named: "arkanoid-arcade")
    var isSticked: Bool = true
    var animId = 1
    
    init() {
        let tex = atlas.textureNamed("ball")
        tex.filteringMode = .nearest
        super.init(texture: tex, color: .red, size: tex.size())
        
        name = "ball"
        position = CGPoint(x: 224/2 + 8, y:20)
        
        let body = SKPhysicsBody(rectangleOf: CGSize(width: 5, height: 4))
        body.mass = 1
        body.isDynamic = true
        body.allowsRotation = false
        body.affectedByGravity = false
        body.restitution = 0.0
        body.friction = 0.0
        body.categoryBitMask = ArkanoidType.ball.rawValue
        body.collisionBitMask = ArkanoidType.brick.rawValue | ArkanoidType.wall.rawValue | ArkanoidType.vaus.rawValue | ArkanoidType.ennemy.rawValue
        body.contactTestBitMask = ArkanoidType.brick.rawValue | ArkanoidType.wall.rawValue | ArkanoidType.vaus.rawValue | ArkanoidType.ennemy.rawValue
        self.physicsBody = body
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class ArkanoidWallNode: SKSpriteNode {
    let atlas = SKTextureAtlas(named: "arkanoid-arcade")
    var type: ArkanoidWallType
    var isSticked: Bool = true
    var animId = 1
    
    init(pos: CGPoint, type: ArkanoidWallType) {
        self.type = type
        
        let tex = atlas.textureNamed("wall-\(type.rawValue)")
        tex.filteringMode = .nearest
        super.init(texture: tex, color: .red, size: tex.size())
        
        name = "wall"
        position = pos
        
        let body = SKPhysicsBody(rectangleOf: tex.size())
        body.mass = 1
        body.isDynamic = false
        body.allowsRotation = false
        body.affectedByGravity = false
        body.restitution = 0.0
        body.friction = 0.0
        body.categoryBitMask = ArkanoidType.wall.rawValue
        body.collisionBitMask = ArkanoidType.ball.rawValue | ArkanoidType.ennemy.rawValue
        body.contactTestBitMask = ArkanoidType.ball.rawValue | ArkanoidType.ennemy.rawValue
        self.physicsBody = body
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

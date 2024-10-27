//
//  FourInARowGameScene.swift
//  GKE
//
//  Created by Alvin Heib on 27/10/2024.
//

import GameplayKit

class FourInARowGameScene: SKScene {
    var players = [FourInARowPlayer]()
    var models = [FourInARowModel]()
    var strategist: GKMinmaxStrategist!

//    var deltaTime: TimeInterval = 0
//    var previousTime: TimeInterval = 0
//    var time: TimeInterval = 0
//    var timer: TimeInterval = 1
    
    var isGameOver: Bool = false
    
    class func newGameScene() -> FourInARowGameScene {
        // Load 'FourInARowGameScene.sks' as an SKScene.
        guard let scene = SKScene(fileNamed: "FourInARowGameScene") as? FourInARowGameScene else {
            print("Failed to load FourInARowGameScene.sks")
            abort()
        }
        
        // Set the scale mode to scale to fit the window
        scene.scaleMode = .aspectFit
        
        return scene
    }
    
    override func didMove(to view: SKView) {
        resetModel()
        resetUI()
    }
    
    func resetModel() {
        players = [ FourInARowPlayer(playerId: 1, chip: .red, isCPU: true),
                    FourInARowPlayer(playerId: 2, chip: .yellow, isCPU: true) ]
        models = [FourInARowModel()]
        
        models[0].players = players
        models[0].activePlayer = players[0]
        
        print(models[0])
        
        strategist = GKMinmaxStrategist()
        strategist.maxLookAheadDepth = 1
        strategist.randomSource = GKARC4RandomSource()
        strategist.gameModel = models[0]
        
        isGameOver = false
    }
    
    func resetUI() {
        self.removeAllChildren()
        
        for row in 0...models[0].rows-1 {
            for col in 0...models[0].cols-1 {
                addChipNode(move: FourInARowMove(col: col, row: row, chip: .none))
            }
        }
    }
    /*
    override func update(_ currentTime: TimeInterval) {
        deltaTime = currentTime - previousTime
        
        time += deltaTime
        if time > timer {
            update()
            time = 0
        }
        previousTime = currentTime
    }
    */
    func update() {
        if isGameOver == true {
            return
        }
        
        if (models[0].activePlayer as! FourInARowPlayer).isCPU {
            let move = strategist.bestMove(for: models[0].activePlayer!) as! FourInARowMove
            print("BEST MOVE: \(move.col) \(move.row) \(move.chip)")
            
            models[0].set(move: move)
            addChipNode(move: move)
            print(models[0])
            
            if models[0].isWin(for: models[0].activePlayer!) {
                addLabelNode(text: "Player \(players[models[0].activePlayer!.playerId - 1].chip) Wins !!!")
                isGameOver = true
                return
            } else if models[0].gameModelUpdates(for: models[0].activePlayer!) == nil {
                addLabelNode(text: "Draw Game !!!")
                isGameOver = true
                return
            }
            
            models[0].activePlayer = models[0].nextPlayer
        }
    }
                            
    func addChipNode(move: FourInARowMove) {
        let node = SKSpriteNode(imageNamed: "fourinarow-\(move.chip)-chip")
        node.name = "\(move.chip)"
        node.anchorPoint = .zero
        node.position = CGPoint(x: move.col * 64, y: move.row * 64)
        node.zPosition = (move.chip == .none ? 0 : -10)
        addChild(node)
    }
    
    func addLabelNode(text: String) {
        let label = SKLabelNode(text: text)
        label.name = "GameLabel"
        label.fontSize = 32
        label.verticalAlignmentMode = .center
        label.position = CGPoint(x: frame.width / 2, y: frame.height / 2)
        label.zPosition = 10
        addChild(label)
        
        print(text)
    }
}

#if os(iOS) || os(tvOS)
// Touch-based event handling
extension FourInARowGameScene {

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
extension FourInARowGameScene {

    override func mouseDown(with event: NSEvent) {
        update()
    }
    
    override func mouseDragged(with event: NSEvent) {
        
    }
    
    override func mouseUp(with event: NSEvent) {
        
    }

}
#endif


enum FourInARowChip: Int {
    case none   = 0
    case red
    case yellow
    
    func getChar() -> String {
        switch self {
        case .none:     return "."
        case .red:      return "R"
        case .yellow:   return "Y"
        }
    }
}

class FourInARowModel: NSObject, GKGameModel {
    var cols: Int = 7
    var rows: Int = 6
    var datas = [FourInARowChip]()
    
    var players: [GKGameModelPlayer]?
    var activePlayer: GKGameModelPlayer?
    var nextPlayer: GKGameModelPlayer {
        if activePlayer!.playerId == players![0].playerId {
            return players![1]
        }
        return players![0]
    }
    
    override var description: String {
        var str = "MODEL: player \((activePlayer as! FourInARowPlayer).chip) turn.\n"
        for row in 0...rows-1 {
            for col in 0...cols-1 {
                str += datas[coord2index(col: col, row: rows-row-1)].getChar()
            }
            str += "\n"
        }
        return str
    }
    
    subscript(col: Int, row: Int) -> FourInARowChip {
        get {
            return datas[coord2index(col: col, row: row)]
        }
        set {
            datas[coord2index(col: col, row: row)] = newValue
        }
    }
    
    override init() {
        datas = Array(repeating: .none, count: cols * rows)
        super.init()
    }
    
    func coord2index(col: Int, row: Int) -> Int {
        return row * cols + col
    }
    
    func set(move: FourInARowMove) {
        datas[coord2index(col: move.col, row: move.row)] = move.chip
    }
    
    func lowest(_ col: Int) -> Int? {
        var row = 0
        while row < rows {
            if datas[coord2index(col: col, row: row)] == .none {
                return row
            }
            row += 1
        }
        
        return nil
    }
    
    func testFourInARow(col: Int, row: Int, dx: Int, dy: Int, chip: FourInARowChip) -> Bool {
        if (col + dx * 3 >= cols) || (col + dx * 3 < 0) || (row + dy * 3 >= rows) || (row + dy * 3 < 0) {
            return false
        }
        
        for id in 0...3 {
            if datas[coord2index(col: col + dx * id, row: row + dy * id)] != chip {
                return false
            }
        }
        return true
    }
    
    // GKGameModel Stubs
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = FourInARowModel()
        copy.setGameModel(self)
        return copy
    }
    
    func setGameModel(_ gameModel: GKGameModel) {
        if let model = gameModel as? FourInARowModel {
            datas = model.datas
            players = model.players
            activePlayer = model.activePlayer
        }
    }
    
    func gameModelUpdates(for player: GKGameModelPlayer) -> [GKGameModelUpdate]? {
        let chip = (player as! FourInARowPlayer).chip
        
        var moves = [FourInARowMove]()
        for col in 0...cols-1 {
            if let row = lowest(col) {
                moves.append(FourInARowMove(col: col, row: row, chip: chip))
            }
        }
        
        if moves == [] {
            return nil
        }
        
        return moves
    }
    
    func apply(_ gameModelUpdate: GKGameModelUpdate) {
        if let move = gameModelUpdate as? FourInARowMove {
            set(move: move)
            activePlayer = nextPlayer
        }
    }
    
    func score(for player: GKGameModelPlayer) -> Int {
        if isWin(for: activePlayer!) {
            return 1000
        } else if isWin(for: nextPlayer){
            return -1000
        }
        return 0
    }
    
    func isWin(for player: GKGameModelPlayer) -> Bool {
        let chip = (player as! FourInARowPlayer).chip
        
        for row in 0...rows-1 {
            for col in 0...cols-1 {
                if testFourInARow(col: col, row: row, dx: 1, dy: 0, chip: chip) {
                    return true
                }
                if testFourInARow(col: col, row: row, dx: 0, dy: 1, chip: chip) {
                    return true
                }
                if testFourInARow(col: col, row: row, dx: 1, dy: 1, chip: chip) {
                    return true
                }
                if testFourInARow(col: col, row: row, dx: 1, dy: -1, chip: chip) {
                    return true
                }
            }
        }
        
        return false
    }
}

class FourInARowPlayer: NSObject, GKGameModelPlayer {
    var playerId: Int
    var chip: FourInARowChip
    var isCPU: Bool
    
    init(playerId: Int, chip: FourInARowChip, isCPU: Bool = false) {
        self.playerId = playerId
        self.chip = chip
        self.isCPU = isCPU
        super.init()
    }
}

class FourInARowMove: NSObject, GKGameModelUpdate {
    var value: Int
    var col: Int
    var row: Int
    var chip: FourInARowChip
    
    override var debugDescription: String {
        return "MOVE: \(col) \(row) \(chip)"
    }
    
    init(col: Int, row: Int, chip: FourInARowChip) {
        self.col = col
        self.row = row
        self.chip = chip
        self.value = 0
        super.init()
    }
}

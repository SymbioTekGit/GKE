//
//  FourInARowGameScene.swift
//  GKE
//
//  Created by Alvin Heib on 27/10/2024.
//

import GameplayKit

class FourInARowGameScene: SKScene {
    var model = FourInARowModel()
    var strategist: GKMinmaxStrategist!

    var deltaTime: TimeInterval = 0
    var previousTime: TimeInterval = 0
    var time: TimeInterval = 0
    var timer: TimeInterval = 1
    
    var col: Int = 0
    var row: Int = 0
    var chipNode = SKSpriteNode()
    
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
        FourInARowPlayer.players = [
            FourInARowPlayer(playerId: 1, chip: .red, isCPU: false),
            FourInARowPlayer(playerId: 2, chip: .yellow, isCPU: true) ]
        
        model = FourInARowModel()
        
        model.players = FourInARowPlayer.players
        model.activePlayer = FourInARowPlayer.players[0]
        
//        print(model)
        
        strategist = GKMinmaxStrategist()
        strategist.maxLookAheadDepth = 5
        strategist.randomSource = GKARC4RandomSource()
        strategist.gameModel = model
    }
    
    func resetUI() {
        self.removeAllChildren()
        
        for row in 0...model.rows-1 {
            for col in 0...model.cols-1 {
                let node = chipNode(col: col, row: row, chip: .none)
                node.zPosition = 0
                addChild(node)
            }
        }
        
        col = 0
        row = model.rows
        chipNode = chipNode(col: col, row: row, chip: (model.activePlayer as! FourInARowPlayer).chip)
        chipNode.isHidden = false
        addChild(chipNode)
    }
    
    override func update(_ currentTime: TimeInterval) {
        deltaTime = currentTime - previousTime
        
        time += deltaTime
        if time > timer {
            if chipNode.isHidden == false {
                if (model.activePlayer as! FourInARowPlayer).isCPU {
                    let move = strategist.bestMove(for: model.activePlayer!) as! FourInARowMove
//                    print("BEST MOVE: \(move.col) \(move.row) \(move.chip)")
                    
                    chipNodeUpdate(col: move.col, row: model.rows, chip: move.chip)
                    
                    model.set(move: move)
                    let node = chipNode(col: move.col, row: move.row, chip: move.chip)
                    addChild(node)
                    
                    update()
                }
            }
            time = 0
        }
        previousTime = currentTime
    }

    func update() {
        if model.isWin(for: model.activePlayer!) {
            addLabelNode(text: "Player \((model.activePlayer as! FourInARowPlayer).chip) Wins !!!")
            chipNode.isHidden = true
            return
        } else if model.gameModelUpdates(for: model.activePlayer!) == nil {
            addLabelNode(text: "Draw Game !!!")
            chipNode.isHidden = true
            return
        }
            
        changePlayerTurn()
    }
    
    func changePlayerTurn() {
        let nextPlayer = (model.activePlayer as! FourInARowPlayer).nextPlayer
        model.activePlayer = nextPlayer
        
        chipNodeUpdate(col: col, row: model.rows, chip: nextPlayer.chip)
    }
    
    func chipNodeUpdate(col: Int, row: Int, chip: FourInARowChip) {
        self.col = col
        self.row = row
        let chip = (model.activePlayer as! FourInARowPlayer).chip
        chipNode.texture = SKTexture(imageNamed: "fourinarow-\(chip)-chip")
        chipNode.position = CGPoint(x: col * 64, y: row * 64)
    }
    
    func chipNode(col: Int, row: Int, chip: FourInARowChip) -> SKSpriteNode {
        let node = SKSpriteNode(imageNamed: "fourinarow-\(chip)-chip")
        node.name = "\(chip)"
        node.anchorPoint = .zero
        node.position = CGPoint(x: col * 64, y: row * 64)
        node.zPosition = -10
        return node
    }
    
    func addLabelNode(text: String) {
        let label = SKLabelNode(text: text)
        label.name = "GameLabel"
        label.fontName = "Chalkduster"
        label.fontSize = 32
        label.verticalAlignmentMode = .center
        label.position = CGPoint(x: frame.width / 2, y: frame.height / 2)
        label.zPosition = 10
        addChild(label)
        
//        print(text)
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
        
    }
    
    override func mouseDragged(with event: NSEvent) {
        if (model.activePlayer as! FourInARowPlayer).isCPU {
            return
        }
        
        let position = event.location(in: self)
        var col = Int(position.x / 64)
        if col < 0 {
            col = 0
        }
        if col >= model.cols {
            col = model.cols - 1
        }
        
        let chip = (model.activePlayer as! FourInARowPlayer).chip
        chipNodeUpdate(col: col, row: model.rows, chip: chip)
    }
    
    override func mouseUp(with event: NSEvent) {
        if (model.activePlayer as! FourInARowPlayer).isCPU {
            return
        }
        if let row = model.lowest(col) {
            let chip = (model.activePlayer as! FourInARowPlayer).chip
            model.set(move: FourInARowMove(col: col, row: row, chip: chip))
            let node = chipNode(col: col, row: row, chip: chip)
            addChild(node)
        }
        
        update()
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
    
    func neighbours(col: Int, row: Int, chip: FourInARowChip) -> Int {
        var count = 0
        for y in 0...2 {
            for x in 0...2 {
                let dx = x - 1
                let dy = y - 1
                if (col + dx < 0) || (col + dx >= cols) || (row + dy < 0) || (row + dy >= rows) {
                    continue
                }
                let neighbour = datas[coord2index(col: col + dx, row: row + dy)]
                if neighbour == .none {
                    continue
                }
                if neighbour == chip {
                    count += 10
                } else {
                    count += 1
                }
            }
        }
        return count
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
                let neighbours = neighbours(col: col, row: row, chip: chip)
                moves.append(FourInARowMove(col: col, row: row, chip: chip, value: neighbours))
            }
        }
        
//        print(moves)
        
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
        let chip = (player as! FourInARowPlayer).chip
        var score = 0
        
        if isWin(for: activePlayer!) {
            score += 100000
        } else if isLoss(for: activePlayer!) {
            score -= -100000
        }
        
        for row in 0...rows-1 {
            for col in 0...cols-1 {
                let neighbours = neighbours(col: col, row: row, chip: chip)
                score += neighbours
            }
        }
        
        return score
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
    
    func isLoss(for player: GKGameModelPlayer) -> Bool {
        return isWin(for: (player as! FourInARowPlayer).nextPlayer)
    }
}

class FourInARowPlayer: NSObject, GKGameModelPlayer {
    static var players = [FourInARowPlayer]()
    
    var playerId: Int
    var chip: FourInARowChip
    var isCPU: Bool
    
    var nextPlayer: FourInARowPlayer {
        if FourInARowPlayer.players[0].playerId == playerId {
            return FourInARowPlayer.players[1]
        }
        return FourInARowPlayer.players[0]
    }
    
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
        return "MOVE: \(col) \(row) \(chip) \(value)"
    }
    
    init(col: Int, row: Int, chip: FourInARowChip, value: Int = 0) {
        self.col = col
        self.row = row
        self.chip = chip
        self.value = value
        super.init()
    }
}

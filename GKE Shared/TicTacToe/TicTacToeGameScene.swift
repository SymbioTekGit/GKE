//
//  ColumnsGameScene.swift
//  GKE
//
//  Created by Alvin Heib on 04/11/2024.
//

import GameplayKit

class TicTacToeGameScene: SKScene {
    var game: TicTacToeGameEntity!
    var deltaTime: TimeInterval = 0
    var previousTime: TimeInterval = 0
    
    class func newGameScene() -> TicTacToeGameScene {
        // Load 'TicTacToeGameScene.sks' as an SKScene.
        guard let scene = SKScene(fileNamed: "TicTacToeGameScene") as? TicTacToeGameScene else {
            print("Failed to load TicTacToeGameScene.sks")
            abort()
        }
        
        // Set the scale mode to scale to fit the window
        scene.scaleMode = .aspectFit
        
        return scene
    }
    
    override func didMove(to view: SKView) {
        let players = [
            TicTacToePlayerModel(playerId: 1, type: TicTacToeType(rawValue: 1)!, isCPU: false),
            TicTacToePlayerModel(playerId: 2, type: TicTacToeType(rawValue: 2)!, isCPU: true) ]
        game = TicTacToeGameEntity(players: players, node: self.childNode(withName: "gamelayer")!)
    }
    
    override func update(_ currentTime: TimeInterval) {
        deltaTime = currentTime - previousTime
        
        game.update(deltaTime: deltaTime)
        
        previousTime = currentTime
    }
}

#if os(iOS) || os(tvOS)
// Touch-based event handling
extension TicTacToeGameScene {

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
extension TicTacToeGameScene {

    override func mouseDown(with event: NSEvent) {
        
    }
    
    override func mouseDragged(with event: NSEvent) {
       
    }
    
    override func mouseUp(with event: NSEvent) {
        let gamelayer = game.visual.node
        let position = event.location(in: gamelayer)
        
        game.apply(position: position)
    }
}
#endif

enum TicTacToeType: Int {
    case none   = 0
    case O      = 1
    case X      = 2
    
    var str: String {
        switch self {
        case .none: return "."
        case .O:    return "O"
        case .X:    return "X"
        }
    }
}

class TicTacToePlayerModel: GKComponent, GKGameModelPlayer {
    var playerId: Int
    var isCPU: Bool
    var type: TicTacToeType
    
    init(playerId: Int, type: TicTacToeType, isCPU: Bool = false) {
        self.playerId = playerId
        self.isCPU = isCPU
        self.type = type
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class TicTacToeGameEntity: GKEntity {
    var players: [TicTacToePlayerModel]
    var model: TicTacToeGameModel
    var visual: TicTacToeGameVisual
    var strategist: GKMinmaxStrategist!
    
    var state: GKStateMachine!
    
    var time: TimeInterval = 0
    var timer: TimeInterval = 1
    
    var winner: TicTacToePlayerModel? = nil
    var isActive: Bool = true
    
    init(players: [TicTacToePlayerModel], node: SKNode) {
        self.players = players
        
        self.model = TicTacToeGameModel()
        self.model.reset(players: players, activePlayer: players[0])
        print(self.model)
        
        self.visual = TicTacToeGameVisual(node: node)
        
        self.strategist = GKMinmaxStrategist()
        self.strategist.maxLookAheadDepth = 5
        self.strategist.randomSource = GKARC4RandomSource()
        self.strategist.gameModel = self.model
        super.init()
        
        addComponent(model)
        addComponent(visual)
        
        self.state = GKStateMachine(states: [ TicTacToeGameRunState(entity: self), TicTacToeGameEndState(entity: self)])
        state.enter(TicTacToeGameRunState.self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        time += seconds
        if time > timer {
            state.currentState?.update(deltaTime: seconds)
            time = 0
        }
    }
    
    func apply(position: CGPoint) {
        (state.currentState as! TicTacToeGameState).apply(position: position)
    }
}

class TicTacToeGameState: GKState {
    func apply(position: CGPoint) {
        
    }
}

class TicTacToeGameRunState: TicTacToeGameState {
    var entity: TicTacToeGameEntity
    
    init(entity: TicTacToeGameEntity) {
        self.entity = entity
        super.init()
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        if stateClass == TicTacToeGameEndState.self {
            return true
        }
        return false
    }
    
    override func didEnter(from previousState: GKState?) {
        print("ENTERED: TicTacToeGameRunState")
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        guard let player = entity.model.activePlayer as? TicTacToePlayerModel else {
            return
        }
        
        if player.isCPU == true {
            print("\nBEST MOVE FOR PLAYER \(player.type)\n")
            let move = entity.strategist.bestMove(for: player) as! TicTacToeUpdateModel
            entity.visual.apply(move: move)
            entity.model.apply(move)
            print(entity.model)
            
            updateGameState(player: player)
        }
    }
    
    func updateGameState(player: TicTacToePlayerModel) {
        // Check Game State
        if entity.model.isWin(for: player) {
            print("Player \(player.playerId) wins with \(player.type) !!!")
            entity.winner = player
            entity.state.enter(TicTacToeGameEndState.self)
            return
        }
        
        if entity.model.gameModelUpdates(for: entity.model.activePlayer!)!.count == 0 {
            print("Game Draw !!!")
            entity.winner = nil
            entity.state.enter(TicTacToeGameEndState.self)
            return
        }
    }
    
    override func apply(position: CGPoint) {
        let player = (entity.model.activePlayer as! TicTacToePlayerModel)
        if player.isCPU {
            return
        }
        
        var col = Int(position.x / 460)
        if col < 0 {
            col = 0
        }
        if col >= entity.model.cols {
            col = entity.model.cols - 1
        }
        
        var row = Int(position.y / 460)
        if row < 0 {
            row = 0
        }
        if row >= entity.model.rows {
            row = entity.model.rows - 1
        }
        
        print("\(col) \(row)")
        if entity.model.blocks[row][col] == .none {
            let move = TicTacToeUpdateModel(col: col, row: row, type: player.type)
            entity.visual.apply(move: move)
            entity.model.apply(move)
            print(entity.model)
            
            updateGameState(player: player)
        }
    }
}

class TicTacToeGameEndState: TicTacToeGameState {
    var entity: TicTacToeGameEntity
    
    init(entity: TicTacToeGameEntity) {
        self.entity = entity
        super.init()
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        if stateClass == TicTacToeGameRunState.self {
            return true
        }
        return false
    }
    
    override func didEnter(from previousState: GKState?) {
        print("ENTERED: TicTacToeGameEndState")
    }
    
    override func apply(position: CGPoint) {
        entity.model.reset(players: entity.players, activePlayer: entity.players[0])
        entity.visual.reset()
        entity.state.enter(TicTacToeGameRunState.self)
    }
}

class TicTacToeGameVisual: GKSKNodeComponent {
    override init(node: SKNode) {
        super.init(node: node)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func reset() {
        node.removeAllChildren()
    }
    
    func apply(move: TicTacToeUpdateModel) {
        let tile = SKSpriteNode(texture: SKTexture(imageNamed: "tictactoe-\(move.type)"))
        tile.position = CGPoint(x: move.col * 460 + 230, y: move.row * 460 + 230)
        node.addChild(tile)
    }
}

class TicTacToeGameModel: GKComponent, GKGameModel {
    let cols = 3
    let rows = 3
    var blocks = [[TicTacToeType]]()
    
    var players: [GKGameModelPlayer]?
    var activePlayer: GKGameModelPlayer?
    var nextPlayer: GKGameModelPlayer? {
        if let index = players?.firstIndex(where: { $0.playerId == activePlayer!.playerId }) {
            let next = (index + 1) % players!.count
            return players![next]
        }
        return nil
    }
    
    override var description: String {
        var str = "TicTacToe Board:\n"
        for row in 0...2 {
            for col in 0...2 {
                str += "\(blocks[rows - row - 1][col].str) "
            }
            str += "\n"
        }
        
        return str
    }
    
    override init() {
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func reset(players: [TicTacToePlayerModel], activePlayer: TicTacToePlayerModel) {
        self.players = players
        self.activePlayer = activePlayer
        blocks = Array(repeating: Array(repeating: .none, count:cols), count:rows)
    }
    
    func setGameModel(_ gameModel: GKGameModel) {
        if let model = gameModel as? TicTacToeGameModel {
            self.players = model.players
            self.activePlayer = model.activePlayer
            self.blocks = model.blocks
        }
    }
    
    func gameModelUpdates(for player: GKGameModelPlayer) -> [GKGameModelUpdate]? {
        guard let player = player as? TicTacToePlayerModel else {
            return []
        }
        
        var lists = [TicTacToeUpdateModel]()
        for row in 0...2 {
            for col in 0...2 {
                if blocks[row][col] == .none {
                    lists.append(TicTacToeUpdateModel(col: col, row: row, type: player.type))
                }
            }
        }
        
        return lists
    }
    
    func apply(_ gameModelUpdate: GKGameModelUpdate) {
        guard let update = gameModelUpdate as? TicTacToeUpdateModel else {
            return
        }
        
        blocks[update.row][update.col] = update.type
        activePlayer = nextPlayer
    }
    
    
    func score(for player: GKGameModelPlayer) -> Int {
        if isWin(for: player) {
            return 1000
        }
        if isLoss(for: nextPlayer!) {
            return -1000
        }
        return 0
    }
    
    func isWin(for player: GKGameModelPlayer) -> Bool {
        guard let player = player as? TicTacToePlayerModel else {
            return false
        }
        
        for id in 0...2 {
            // horizontal match
            if isMatch3(col: 0, row: id, dx: 1, dy: 0, type: player.type) {
                return true
            }
            // vertical match
            if isMatch3(col: id, row: 0, dx: 0, dy: 1, type: player.type) {
                return true
            }
        }
        
        // diagonal up / right match
        if isMatch3(col: 0, row: 0, dx: 1, dy: 1, type: player.type) {
            return true
        }
        
        // diagonal down / right match
        if isMatch3(col: 0, row: 2, dx: 1, dy: -1, type: player.type) {
            return true
        }
        
        return false
    }
    
    func isLoss(for player: GKGameModelPlayer) -> Bool {
        return isWin(for: nextPlayer!)
    }
    
    func isMatch3(col: Int, row: Int, dx: Int, dy: Int, type: TicTacToeType) -> Bool {
        for id in 0...2 {
            if blocks[row + dy * id][col + dx * id] != type {
                return false
            }
        }
        return true
    }
}

class TicTacToeUpdateModel: GKComponent, GKGameModelUpdate {
    var value: Int = 1
    var col: Int
    var row: Int
    var type: TicTacToeType
    
    override var description: String {
        return "(\(col), \(row))"
    }
    
    init(col: Int, row: Int, type: TicTacToeType) {
        self.col = col
        self.row = row
        self.type = type
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

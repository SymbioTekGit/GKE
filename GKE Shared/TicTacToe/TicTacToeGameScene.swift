//
//  ColumnsGameScene.swift
//  GKE
//
//  Created by Alvin Heib on 04/11/2024.
//

import GameplayKit

class TicTacToeGameScene: SKScene {
    var models = [TicTacToeGameModel]()
    var strategist: GKMinmaxStrategist!
    
    var deltaTime: TimeInterval = 0
    var previousTime: TimeInterval = 0
    
    var time: TimeInterval = 0
    var timer: TimeInterval = 1
    
    var winner: TicTacToePlayerModel? = nil
    var isActive: Bool = true
    
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
        TicTacToePlayerModel.players = [ TicTacToePlayerModel(playerId: 1, type: TicTacToeType(rawValue: 1)!, isCPU: false), TicTacToePlayerModel(playerId: 2, type: TicTacToeType(rawValue: 2)!, isCPU: true) ]
        let model = TicTacToeGameModel()
        model.reset(players: TicTacToePlayerModel.players, activePlayer: TicTacToePlayerModel.players[0])
        models.append(model)
        
        strategist = GKMinmaxStrategist()
        strategist.maxLookAheadDepth = 5
        strategist.randomSource = GKARC4RandomSource()
        strategist.gameModel = model
        
        print(model)
    }
    
    override func update(_ currentTime: TimeInterval) {
        deltaTime = currentTime - previousTime
        
        time += deltaTime
        if time > timer {
            if isActive {
                update()
            }
            
            time = 0
        }
        
        previousTime = currentTime
    }
    
    func update() {
        guard let player = models[0].activePlayer as? TicTacToePlayerModel else {
            return
        }
        
        if player.isCPU == true {
            print("\nBEST MOVE FOR PLAYER \(player.type)\n")
            let move = strategist.bestMove(for: player) as! TicTacToeUpdateModel
            apply(move: move)
            models[0].apply(move)
            print(models[0])
            
            updateGameState(player: player)
        }
    }
    
    func updateGameState(player: TicTacToePlayerModel) {
        // Check Game State
        if models[0].isWin(for: player) {
            print("Player \(player.playerId) wins with \(player.type) !!!")
            isActive = false
            winner = player
            return
        }
        
        if models[0].gameModelUpdates(for: models[0].activePlayer!)!.count == 0 {
            print("Game Draw !!!")
            isActive = false
            winner = nil
            return
        }
    }
    
    func apply(move: TicTacToeUpdateModel) {
        let gamelayer = childNode(withName: "gamelayer")!
        let tile = SKSpriteNode(texture: SKTexture(imageNamed: "tictactoe-\(move.type)"))
        tile.position = CGPoint(x: move.col * 460 + 230, y: move.row * 460 + 230)
        gamelayer.addChild(tile)
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
        let gamelayer = childNode(withName: "gamelayer")!
        
        if isActive == false {
            models[0].reset(players: TicTacToePlayerModel.players, activePlayer: TicTacToePlayerModel.players[0])
            gamelayer.removeAllChildren()
            isActive = true
        }
        
        guard let player = (models[0].activePlayer as? TicTacToePlayerModel) else {
            return
        }
                
        if player.isCPU {
            return
        }
        
        let position = event.location(in: gamelayer)
        print(position)
        var col = Int(position.x / 460)
        if col < 0 {
            col = 0
        }
        if col >= models[0].cols {
            col = models[0].cols - 1
        }
        
        var row = Int(position.y / 460)
        if row < 0 {
            row = 0
        }
        if row >= models[0].rows {
            row = models[0].rows - 1
        }
        print("\(col) \(row)")
        if models[0].blocks[row][col] == .none {
            let move = TicTacToeUpdateModel(col: col, row: row, type: player.type)
            apply(move: move)
            models[0].apply(move)
            print(models[0])
            
            updateGameState(player: player)
        }
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

class TicTacToePlayerModel: NSObject, GKGameModelPlayer {
    static var players: [TicTacToePlayerModel] = []
    var playerId: Int
    var isCPU: Bool
    var type: TicTacToeType
    
    var nextPlayer: TicTacToePlayerModel {
        if playerId == TicTacToePlayerModel.players[0].playerId {
            return TicTacToePlayerModel.players[1]
        }
        return TicTacToePlayerModel.players[0]
    }
    
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

class TicTacToeGameModel: NSObject, GKGameModel {
    let cols = 3
    let rows = 3
    var blocks = [[TicTacToeType]]()
    
    var players: [GKGameModelPlayer]?
    var activePlayer: GKGameModelPlayer?
    
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
    
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = TicTacToeGameModel()
        copy.setGameModel(self)
        return copy
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
        activePlayer = (activePlayer as! TicTacToePlayerModel).nextPlayer
    }
    
    
    func score(for player: GKGameModelPlayer) -> Int {
        if isWin(for: player) {
            return 1000
        }
        if isWin(for: (player as! TicTacToePlayerModel).nextPlayer) {
            return -10000
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
    
    func isMatch3(col: Int, row: Int, dx: Int, dy: Int, type: TicTacToeType) -> Bool {
        for id in 0...2 {
            if blocks[row + dy * id][col + dx * id] != type {
                return false
            }
        }
        return true
    }
}

class TicTacToeUpdateModel: NSObject, GKGameModelUpdate {
    var value: Int = 0
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

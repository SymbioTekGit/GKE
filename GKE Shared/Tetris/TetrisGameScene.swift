//
//  TetrisGameScene.swift
//  GKE
//
//  Created by Alvin Heib on 28/10/2024.
//

import GameplayKit

class TetrisGameScene: SKScene {
    var tilesets = [GKETileSet]()
    var tilelayers = [GKETileLayer]()
    
//    var players = [TetrisGameModelPlayer]()
//    var models = [TetrisGameModel]()
//    var randoms = [GKERandomBag]()
//    
//    var matrixOffsets = [ (dx: 4, dy: 5), (dx: 28, dy: 5) ]
//    var nextOffsets = [ (dx: 0, dy: 25), (dx: 38, dy: 25) ]
    
    var rawDatas: [String: [GKEMetaTile]] = [:]
        
    class func newGameScene() -> TetrisGameScene {
        // Load 'TetrisGameScene.sks' as an SKScene.
        guard let scene = SKScene(fileNamed: "TetrisGameScene") as? TetrisGameScene else {
            print("Failed to load TetrisGameScene.sks")
            abort()
        }
        
        // Set the scale mode to scale to fit the window
        scene.scaleMode = .aspectFit
        
        return scene
    }
    
    override func didMove(to view: SKView) {
        tilesets.append(GKETileSet(imagenamed: "tetris-arcade-tileset", tilewidth: 8, tileheight: 8))
        tilelayers.append(GKETileLayer(name: "tilelayer", cols: 42, rows: 30, tileset: tilesets[0]))
        addChild(tilelayers[0].node)
        
        rawDatas["J"] = [
            GKEMetaTile(col: 4, row: 20, tiles: [ GKETileDef(dx: 0, dy: 1, dg: 33), GKETileDef(dx: 1, dy: 1, dg: 34), GKETileDef(dx: 2, dy: 1, dg: 46), GKETileDef(dx: 2, dy: 0, dg: 38)], tilelayer: tilelayers[0]),
            GKEMetaTile(col: 4, row: 20, tiles: [ GKETileDef(dx: 1, dy: 2, dg: 36), GKETileDef(dx: 1, dy: 1, dg: 37), GKETileDef(dx: 1, dy: 0, dg: 44), GKETileDef(dx: 0, dy: 0, dg: 33)], tilelayer: tilelayers[0])]
        
        let tetromino = rawDatas["J"]![1]
        tetromino.draw(offset: GKECoord(col: 4, row: 5))
        
//        randoms = [GKERandomBag(pattern: [1, 2, 3, 4, 5, 6, 7])]
//         
//        for _ in 0...1 {
//            players.append(TetrisGameModelPlayer(playerId: 1, isCPU: false))
//            
//            let model = TetrisGameModel()
//            model.players = players
//            model.activePlayer = players.last!
//            model.random = randoms.last!
//            model.swap()
//            model.swap()
//            models.append(model)
//            
//            for tetrominoId in 0...models.last!.tetrominos.count-1 {
//                draw(tetrominoId: tetrominoId, modelId: models.count - 1)
//            }
//        }
    }
    /*
    func set(col: Int, row: Int, gid: Int, modelId: Int = 0) {
        models[modelId].blocks[row][col] = gid
        
        tilelayers[0].update(col: col + matrixOffsets[modelId].dx, row: row + matrixOffsets[modelId].dy, gid: gid)
    }
    
    func draw(tetrominoId: Int, modelId: Int) {
        let tetromino = models[modelId].tetrominos[tetrominoId]
        let offset = tetrominoId == 0 ? nextOffsets[modelId] : matrixOffsets[modelId]
        
        for id in 0...3 {
            let col = tetromino.datas[id * 3] + tetromino.col
            let row = tetromino.datas[id * 3 + 1] + tetromino.row
            let gid = tetromino.datas[id * 3 + 2]
            tilelayers[0].update(col: col + offset.dx, row: row + offset.dy, gid: gid)
        }
    }
    
    func clear(tetrominoId: Int, modelId: Int) {
        let tetromino = models[modelId].tetrominos[tetrominoId]
        let offset = tetrominoId == 0 ? nextOffsets[modelId] : matrixOffsets[modelId]
        
        for id in 0...3 {
            let col = tetromino.datas[id * 3] + tetromino.col
            let row = tetromino.datas[id * 3 + 1] + tetromino.row
            tilelayers[0].update(col: col + offset.dx, row: row + offset.dy, gid: 0)
        }
    }
    
    func rotate(tetrominoId: Int, modelId: Int) {
        clear(tetrominoId: tetrominoId, modelId: modelId)
        models[modelId].tetrominos[tetrominoId].rotate()
        draw(tetrominoId: tetrominoId, modelId: modelId)
    }
     */
}


#if os(iOS) || os(tvOS)
// Touch-based event handling
extension GameScene {

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
extension TetrisGameScene {

    override func keyDown(with event: NSEvent) {
        
    }
    
    override func mouseDown(with event: NSEvent) {
        /*
        for modelId in 0...models.count-1 {
            for tetrominoId in 0...models[modelId].tetrominos.count-1 {
                rotate(tetrominoId: tetrominoId, modelId: modelId)
            }
        }
         */
    }
    
    override func mouseDragged(with event: NSEvent) {
        
    }
    
    override func mouseUp(with event: NSEvent) {
        
    }
}
#endif
/*
enum TetrisTetrominoType: Int {
    case none       = 0
    case I
    case O
    case J
    case L
    case S
    case T
    case Z
    
    var color: SKColor {
        let colors: [SKColor] = [ .red, .yellow, .blue, .orange, .magenta, .cyan, .green]
        return colors[rawValue - 1]
    }
}
*/
class TetrisGameModelPlayer: NSObject, GKGameModelPlayer {
    var playerId: Int
    var isCPU: Bool = false
    var score: Int = 0
    var lines: Int = 0
    var left: Int = 0
    
    override var description: String {
        return "Player: \t playerId: \(playerId) \t isCPU: \(isCPU) \n"
    }
    
    init(playerId: Int, isCPU: Bool) {
        self.playerId = playerId
        super.init()
    }
}

class TetrisTetromino: NSObject, GKGameModelUpdate {
    var value: Int = 0
    var type: Int               // Type: 0 = none, 1 = I, 2 = O, 3 = J, 4 = L, 5 = S, 6 = T, 7 = Z
    var col: Int
    var row: Int
    var rot: Int
    var datas: [Int] = []
    
    /// [ (dx, dy, id), (dx, dy, id), (dx, dy, id), (dx, dy, id) ] format
    let rawDatas = [
        // I = 1 - 16 = red
        [[ -1, 1, 1, 0, 1, 2, 1, 1, 2, 2, 1, 3 ],
         [ 1, 2, 4, 1, 1, 5, 1, 0, 5, 1, -1, 6 ],
         [ 2, 0, 3, 1, 0, 2, 0, 0, 2, -1, 0, 1 ],
         [ 0, -1, 6, 0, 0, 5, 0, 1, 5, 0, 2, 4 ]],
        // O = 49 - 64 = yellow
        [[ 0, 0, 61, 0, 1, 59, 1, 1, 62, 1, 0, 60 ],
         [ 0, 0, 61, 0, 1, 59, 1, 1, 62, 1, 0, 60 ],
         [ 0, 0, 61, 0, 1, 59, 1, 1, 62, 1, 0, 60 ],
         [ 0, 0, 61, 0, 1, 59, 1, 1, 62, 1, 0, 60 ]],
        // J = 33 - 48 = blue
        [[ -1, 0, 33, 0, 0, 34, 1, 0, 46, 1, -1, 38 ],
         [ 0, 1, 36, 0, 0, 37, 0, -1, 44, -1, -1, 33 ],
         [ 1, -1, 35, 0, -1, 34, -1, -1, 45, -1, 0, 36 ],
         [ 0, -1, 38, 0, 0, 37, 0, 1, 43, 1, 1, 35 ]],
        // L = 97 - 112 = orange
        // TBD: missing rotation 1-3
        [[ 0, 1, 99, 0, 0, 98, -1, 0, 107, -1, -1, 102],
         [ 0, 1, 99, 0, 0, 98, -1, 0, 107, -1, -1, 102],
         [ 0, 1, 99, 0, 0, 98, -1, 0, 107, -1, -1, 102],
         [ 0, 1, 99, 0, 0, 98, -1, 0, 107, -1, -1, 102]],
        // S = 65 - 80 = magenta
        // TBD: missing rotation 1-3
        [[ 1, 0, 67, 0, 0, 75, 0, -1, 76, -1, -1, 65],
         [ 1, 0, 67, 0, 0, 75, 0, -1, 76, -1, -1, 65],
         [ 1, 0, 67, 0, 0, 75, 0, -1, 76, -1, -1, 65],
         [ 1, 0, 67, 0, 0, 75, 0, -1, 76, -1, -1, 65]],
        // T = 81 - 96 = cyan
        // TBD: missing rotation 1-3
        [[ 0, -1, 86, 0, 0, 89, -1, 0, 81, 1, 0, 83],
         [ 0, -1, 86, 0, 0, 89, -1, 0, 81, 1, 0, 83],
         [ 0, -1, 86, 0, 0, 89, -1, 0, 81, 1, 0, 83],
         [ 0, -1, 86, 0, 0, 89, -1, 0, 81, 1, 0, 83]],
        // Z = 17 - 32 = green
        // TBD: missing rotation 1-3
        [[ -1, 0, 17, 0, 0, 30, 0, -1, 29, 1, -1, 19],
         [ -1, 0, 17, 0, 0, 30, 0, -1, 29, 1, -1, 19],
         [ -1, 0, 17, 0, 0, 30, 0, -1, 29, 1, -1, 19],
         [ -1, 0, 17, 0, 0, 30, 0, -1, 29, 1, -1, 19]]
    ]
    
    init(type: Int = 1, col: Int = 0, row: Int = 0, rot: Int = 0) {
        self.type = type
        self.col = col
        self.row = row
        self.rot = rot
        super.init()
        
        update(type: type)
    }
    
    func update(type: Int, col: Int = 0, row: Int = 0, rot: Int = 0) {
        self.type = type
        self.col = col
        self.row = row
        self.rot = rot
        self.datas = rawDatas[type - 1][rot]
    }
    
    func rotate() {
        rot = (rot + 1) % 4
        self.datas = rawDatas[type - 1][rot]
    }
    
    func move(col: Int, row: Int) {
        self.col = col
        self.row = row
    }
}

class TetrisGameModel: NSObject {
    var players: [GKGameModelPlayer]?
    var activePlayer: GKGameModelPlayer?
    
    let cols = 10
    let rows = 20 + 4
    var blocks = [[Int]]()      // Type: 0 = none, 1 = I, 2 = O, 3 = J, 4 = L, 5 = S, 6 = T, 7 = Z
    
    var random: GKERandomBag!
    var index: Int = 0
    
    // 0 = next, 1 = tetromino
    var tetrominos = [TetrisTetromino]()
    
    override init() {
        super.init()
        blocks = Array(repeating: Array(repeating: 0, count: cols), count: rows)
        
        for type in 1...2 {
            let tetromino = TetrisTetromino(type: type)
            tetrominos.append(tetromino)
        }
    }
    
    func swap() {
        tetrominos[1].update(type: tetrominos[0].type, col: Int(cols / 2) - 1, row: rows - 4, rot: 0)
        tetrominos[0].update(type: random[index], col: 1, row: 1, rot: 0)
        index += 1
    }
    
    /*
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = TetrisGameModel()
        copy.setGameModel(self)
        return copy
    }
    
    func setGameModel(_ gameModel: GKGameModel) {
        // TBD
        if let model = gameModel as? TetrisGameModel {
            players = model.players
            activePlayer = model.activePlayer
            blocks = model.blocks
            tetromino = model.tetromino
            next = model.next
        }
    }
    
    func gameModelUpdates(for player: GKGameModelPlayer) -> [GKGameModelUpdate]? {
        // TBD
        var updates = [TetrisTetromino]()
        
        var test = TetrisTetromino()
        for rot in 0...3 {
            for col in 0...cols-1 {
                var row = 0
                while (row < rows) {
                    test.update(type: tetromino.type, col: col, row: row, rot: rot)
                    if isPossibleMove(tetromino: test) {
                        break
                    }
                    row += 1
                }
                
                updates.append(test)
            }
        }
        
        return updates
    }
    
    func apply(_ gameModelUpdate: GKGameModelUpdate) {
        if let tetromino = gameModelUpdate as? TetrisTetromino {
            fix(tetromino: tetromino)
        }
        
        while true {
            let lines = getFullRows()
            if lines.count == 0 {
                break
            }
            clearRows(lines)
        }
    }
    
    func fix(tetromino: TetrisTetromino) {
        let col = tetromino.col
        let row = tetromino.row
        
        for id in 0...3 {
            let dx = tetromino.datas[id * 3]
            let dy = tetromino.datas[id * 3 + 1]
            let id = tetromino.datas[id * 3 + 2]
            blocks[row + dy][col + dx] = id
        }
    }
    
    func isPossibleMove(tetromino: TetrisTetromino) -> Bool {
        let col = tetromino.col
        let row = tetromino.row
        
        for id in 0...3 {
            let dx = tetromino.datas[id * 3]
            let dy = tetromino.datas[id * 3 + 1]
            let id = tetromino.datas[id * 3 + 2]
            if (col + dx < 0) || (col + dx > cols - 1) || (row + dy < 0) || (row + dy > rows - 1) {
                return false
            }
        }
        
        return true
    }
    
    func elementCountRow(_ line: Int) -> Int {
        var count = 0
        for col in 0...cols-1 {
            if blocks[line][col] != 0 {
                count += 1
            }
        }
        return count
    }
    
    func clearRow(_ line: Int) {
        for col in 0...cols-1 {
            blocks[line][col] = 0
        }
    }
    
    func clearRows(_ lines: [Int]) {
        for row in lines {
            clearRow(row)
        }
    }
    
    func dropRow(_ line: Int) {
        for row in line...rows-1 {
            for col in 0...cols-1 {
                blocks[row-1][col] = blocks[row][col]
            }
        }
        clearRow(rows-1)
    }
    
    func isLost() -> Bool {
        let value = elementCountRow(20) + elementCountRow(21) + elementCountRow(22) + elementCountRow(23)
        
        return value != 0
    }
    
    func getFullRows() -> [Int] {
        var lines = [Int]()
        
        for row in 0...rows-1 {
            if elementCountRow(row) == cols {
                lines.append(row)
            }
        }
        
        return lines
    }
     */
}

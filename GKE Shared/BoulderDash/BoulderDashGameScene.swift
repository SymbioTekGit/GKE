//
//  BoulderDashGameScene.swift
//  GKE
//
//  Created by Alvin Heib on 16/11/2024.
//

import GameplayKit

class BoulderDashGameScene: SKScene {
    var caveId = 1
    var difficultyId = 1
    
    var tilesets = [GKETileSet]()
    var tilelayers = [GKETileLayer]()
    var cave: BoulderDashCave!
    
    var stateMachine: GKStateMachine!
    var deltaTime: TimeInterval = 0
    var previousTime: TimeInterval = 0
    var time: TimeInterval = 0
    var timer: TimeInterval = 0.5
    
    class func newGameScene() -> BoulderDashGameScene {
        // Load 'BoulderDashGameScene.sks' as an SKScene.
        guard let scene = SKScene(fileNamed: "BoulderDashGameScene") as? BoulderDashGameScene else {
            print("Failed to load BoulderDashGameScene.sks")
            abort()
        }
        
        // Set the scale mode to scale to fit the window
        scene.scaleMode = .aspectFit
        
        return scene
    }
    
    override func didMove(to view: SKView) {
        stateMachine = GKStateMachine(states: [BoulderDashInitialState(self), BoulderDashRunState(self)])
        stateMachine.enter(BoulderDashInitialState.self)
    }

    override func update(_ currentTime: TimeInterval) {
        deltaTime = currentTime - previousTime
        
        time += deltaTime
        if time > timer {
            stateMachine.currentState!.update(deltaTime: timer)
            time = 0
        }
        
        previousTime = currentTime
    }
}

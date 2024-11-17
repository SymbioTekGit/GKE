//
//  BoulderDashRunState.swift
//  GKE
//
//  Created by Alvin Heib on 17/11/2024.
//

import GameplayKit

class BoulderDashRunState: GKState {
    var scene: BoulderDashGameScene
    
    init(_ scene: BoulderDashGameScene) {
        self.scene = scene
        super.init()
    }
    
    override func didEnter(from previousState: GKState?) {
        if let preRockford = scene.cave.find(type: .preRockford) {
            scene.cave.update(col: preRockford.col, row: preRockford.row, type: .rockford)
        }
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        scene.cave.animate()
        
        let _ = scene.cave.isFallingCompleted()
    }
}

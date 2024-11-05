//
//  GKERandomBag.swift
//  GKE
//
//  Created by Alvin Heib on 03/11/2024.
//

import GameplayKit


class GKERandomBag: NSObject {
    var random: GKARC4RandomSource
    var randoms: [Int] = []
    var pattern = [Int]()
    var count: Int = 0
    
    subscript(index: Int) -> Int {
        get {
            while(index >= randoms.count) {
                generate()
            }
            return randoms[index]
        }
        set {
            while(index >= randoms.count) {
                generate()
            }
            randoms[index] = newValue
        }
    }
    
    init(pattern: [Int], count: Int = 1, source: String = "RANDOM") {
        self.random = GKARC4RandomSource(seed: Data(source.utf8))
        self.pattern = pattern
        self.count = count
        super.init()
    }
    
    func generate() {
        for _ in 0...count-1 {
            randoms += pattern.shuffled()
        }
    }
}

//
//  GKETileSet.swift
//  GKE
//
//  Created by Alvin Heib on 02/11/2024.
//

import GameplayKit

class GKETileSet: NSObject {
    var firstGid: Int = 1
    var tilewidth: Int = 8
    var tileheight: Int = 8
    var images: [CGImage] = []
    
    var cgSize: CGSize {
        return CGSize(width: tilewidth, height: tileheight)
    }
    
    subscript(index: Int) -> CGImage {
        get {
            let id = index - firstGid
            return images[id]
            
        }
        set {
            let id = index - firstGid
            images[id] = newValue
        }
    }
    
    init(imagenamed: String, tilewidth: Int, tileheight: Int, tilecount: Int = -1) {
        let image = SKTexture(imageNamed: imagenamed).cgImage()
        
        let cols = Int(image.width / tilewidth)
        let rows = Int(image.height / tileheight)
        let count = tilecount == -1 ? rows * cols : tilecount
        
        var id = 0
        while id < count {
            let row = Int(id / cols)
            let col = id % cols
            let rect = CGRect(x: col * tilewidth, y: row * tileheight, width: tilewidth, height: tileheight)
            if let img = image.cropping(to: rect) {
                images.append(img)
            }
            id += 1
        }
        
        self.tilewidth = tilewidth
        self.tileheight = tileheight
    }
}

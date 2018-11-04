//
//  Castle.swift
//  PlayAround
//
//  Created by Justin Dike on 1/12/17.
//  Copyright © 2017 Justin Dike. All rights reserved.
//

import Foundation
import SpriteKit

class Castle: SKSpriteNode {
    
    var dudesInCastle:Int = 0
    
    func setUpCastle() {
        
        self.physicsBody?.categoryBitMask = BodyType.castle.rawValue
        self.physicsBody?.collisionBitMask =  BodyType.player.rawValue

        
        print ( "Setup Castle")
    }
    
    
    
}

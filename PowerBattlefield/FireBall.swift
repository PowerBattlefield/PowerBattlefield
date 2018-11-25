//
//  FireBall.swift
//  PowerBattlefield
//
//  Created by Da Lin on 11/24/18.
//  Copyright © 2018 Da Lin. All rights reserved.
//

import Foundation
import SpriteKit

class FireBall: SKSpriteNode {
    init(texture: SKTexture, color: SKColor, size: CGSize, playerPos: CGPoint) {
        super.init(texture: texture, color: color, size: size)
        position = CGPoint(x: playerPos.x, y: playerPos.y)
        physicsBody = SKPhysicsBody(circleOfRadius: 10)
        physicsBody?.categoryBitMask = BodyType.fireball.rawValue
        physicsBody?.affectedByGravity = false
        physicsBody?.collisionBitMask = BodyType.castle.rawValue | BodyType.road.rawValue | BodyType.player1.rawValue
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

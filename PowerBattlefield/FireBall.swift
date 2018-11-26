import Foundation
import SpriteKit

class FireBall: SKSpriteNode {
    init(texture: SKTexture, color: SKColor, size: CGSize, playerPos: CGPoint) {
        super.init(texture: texture, color: color, size: size)
        position = CGPoint(x: playerPos.x, y: playerPos.y)
        physicsBody = SKPhysicsBody(circleOfRadius: 10)
        physicsBody?.categoryBitMask = BodyType.fireball.rawValue
        physicsBody?.affectedByGravity = false
        physicsBody?.collisionBitMask = BodyType.road.rawValue | BodyType.player1.rawValue
        physicsBody?.contactTestBitMask = BodyType.boat.rawValue | BodyType.movingTotem.rawValue | BodyType.building.rawValue | BodyType.enemy.rawValue
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

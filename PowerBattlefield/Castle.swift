import Foundation
import SpriteKit

class Castle: SKSpriteNode {
    
    var dudesInCastle:Int = 0
    
    func setUpCastle() {
        
        self.physicsBody?.categoryBitMask = BodyType.castle.rawValue
        self.physicsBody?.collisionBitMask =  BodyType.player1.rawValue

    }
    
    
    
}

import Foundation
import SpriteKit
import Firebase

enum BodyType:UInt32{
    case player = 1
    case building = 2
    case castle = 4
    case road = 8
    case water = 16
    case rock = 32
    case grass = 64
}

enum PlayerState:Int{
    case left = 1
    case right = 2
    case up = 3
    case down = 4
    case attack = 5
    case walk = 6
    case idle = 7
}

class Player: SKSpriteNode{
    
    var moveSpeed:TimeInterval = 1
    var moveAmount = 0
    var playerLabel: Int = 1
    var roomId: String = "1"
    
    var refx: DatabaseReference = Database.database().reference()
    var refy: DatabaseReference = Database.database().reference()
    var refMoveRight: DatabaseReference = Database.database().reference()
    var refMoveLeft: DatabaseReference = Database.database().reference()
    var refMoveUp: DatabaseReference = Database.database().reference()
    var refMoveDown: DatabaseReference = Database.database().reference()
    
    func initialize(playerLabel: Int, roomId: String){
        self.playerLabel = playerLabel
        self.roomId = roomId
        setDatabaseReference()
        setPhysicsBody()
        idleDownAnimation()
    }
    
    func idleDownAnimation(){
        var textures:[SKTexture] = []
        var animation: SKAction = SKAction()
        for i in 1...4{
            textures.append(SKTexture(imageNamed: "p\(playerLabel)_idledown_0\(i)"))
        }
        animation = SKAction.animate(with: textures, timePerFrame: 0.4)
        run(SKAction.repeatForever(animation))
    }
    
    func setPhysicsBody(){
        self.physicsBody?.categoryBitMask = BodyType.player.rawValue
        self.physicsBody?.collisionBitMask = BodyType.castle.rawValue | BodyType.road.rawValue | BodyType.water.rawValue
        self.physicsBody?.contactTestBitMask = BodyType.building.rawValue | BodyType.castle.rawValue | BodyType.player.rawValue | BodyType.water.rawValue
    }
    
    func setDatabaseReference(){
        refx = Database.database().reference().child(roomId).child("player\(playerLabel)").child("position").child("x")
        refMoveRight = Database.database().reference().child(roomId).child("player\(playerLabel)").child("move").child("right")
        refMoveLeft = Database.database().reference().child(roomId).child("player\(playerLabel)").child("move").child("left")
        refMoveUp = Database.database().reference().child(roomId).child("player\(playerLabel)").child("move").child("up")
        refMoveDown = Database.database().reference().child(roomId).child("player\(playerLabel)").child("move").child("down")
        refy = Database.database().reference().child(roomId).child("player\(playerLabel)").child("position").child("y")
    }
    
    func attack(){
        run(SKAction(named: "p\(playerLabel)_attackdown")!)
        if(playerLabel == 1){
            let theWeapon = (self.childNode(withName: "Sword") as? SKSpriteNode)!
            theWeapon.run(SKAction(named: "sword_attackdown")!)
        }
    }
    
    func moveUp(otherPlayer: Bool){
        if(!otherPlayer){
            moveAmount += 1
            refMoveUp.setValue("\(moveAmount)")
        }
        move(theXAmount: 0, theYAmount: 100, theAnimation: "p\(playerLabel)_walkup")
    }
    
    func moveDown(otherPlayer: Bool){
        if(!otherPlayer){
            moveAmount += 1
            refMoveDown.setValue("\(moveAmount)")
        }
        move(theXAmount: 0, theYAmount: -100, theAnimation: "p\(playerLabel)_walkdown")
    }
    
    func moveLeft(otherPlayer: Bool){
        if(!otherPlayer){
            moveAmount += 1
            refMoveLeft.setValue("\(moveAmount)")
        }
        move(theXAmount: -100, theYAmount: 0, theAnimation: "p\(playerLabel)_walkleft")
    }
    
    func moveRight(otherPlayer: Bool){
        if(!otherPlayer){
            moveAmount += 1
            refMoveRight.setValue("\(moveAmount)")
        }
        move(theXAmount: 100, theYAmount: 0, theAnimation: "p\(playerLabel)_walkright")
    }
    
    func move(theXAmount:CGFloat , theYAmount:CGFloat, theAnimation:String)  {
        let wait:SKAction = SKAction.wait(forDuration: 0.05)
        let walkAnimation:SKAction = SKAction(named: theAnimation, duration: moveSpeed )!
        let moveAction:SKAction = SKAction.moveBy(x: theXAmount, y: theYAmount, duration: moveSpeed )
        let group:SKAction = SKAction.group( [ walkAnimation, moveAction ] )
        let finish:SKAction = SKAction.run {
            //print ( "Finish")
        }
        let seq:SKAction = SKAction.sequence( [wait, group, finish] )
        run(seq)
    }
}

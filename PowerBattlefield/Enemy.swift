import Foundation
import SpriteKit
import Firebase

enum EnemyState:Int{
    case walk = 1
    case idle = 2
    case attack = 3
}

class Enemy:SKSpriteNode{
    var moveSpeed:TimeInterval = 0.5
    var moveAmount = 0
    var moveDistance:CGFloat = 50
    var face = PlayerFace.down
    var enemyLabel = 1
    
    init(texture: SKTexture, color: SKColor, size: CGSize, spawnPos: CGPoint) {
        super.init(texture: texture, color: color, size: size)
        position = CGPoint(x: spawnPos.x, y: spawnPos.y)
        physicsBody = SKPhysicsBody(circleOfRadius: 20)
        physicsBody?.categoryBitMask = BodyType.enemy.rawValue
        physicsBody?.affectedByGravity = false
        physicsBody?.collisionBitMask = BodyType.water.rawValue | BodyType.road.rawValue
        
        idleDownAnimation()
        
    }
    
    func observeStateChange(roomId: String){
        Database.database().reference().child(roomId).child("enemy\(enemyLabel)").observe(DataEventType.value) { (snapshot) in
            var state = 0
            var face = 0
            for rest in snapshot.children.allObjects as! [DataSnapshot]{
                if rest.key == "state"{
                    state = (rest.value as! NSNumber).intValue
                }else if rest.key == "face"{
                    face = (rest.value as! NSNumber).intValue
                }
            }
            if state == EnemyState.attack.rawValue{
                self.attack()
            }
            else if state == EnemyState.walk.rawValue{
                if face == PlayerFace.left.rawValue{
                    self.moveLeft()
                }else if face == PlayerFace.right.rawValue{
                    self.moveRight()
                }else if face == PlayerFace.up.rawValue{
                    self.moveUp()
                }else if face == PlayerFace.down.rawValue{
                    self.moveDown()
                }
            }else if state == EnemyState.idle.rawValue{
                if face == PlayerFace.left.rawValue{
                    self.idleLeftAnimation()
                }else if face == PlayerFace.right.rawValue{
                    self.idleRightAnimation()
                }else if face == PlayerFace.up.rawValue{
                    self.idleUpAnimation()
                }else if face == PlayerFace.down.rawValue{
                    self.idleDownAnimation()
                }
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func idleDownAnimation(){
        var textures:[SKTexture] = []
        var animation: SKAction = SKAction()
        for i in 1...2{
            textures.append(SKTexture(imageNamed: "e1_idledown_0\(i)"))
        }
        animation = SKAction.animate(with: textures, timePerFrame: 0.4)
        run(SKAction.repeatForever(animation))
    }
    
    func idleUpAnimation(){
        var textures:[SKTexture] = []
        var animation: SKAction = SKAction()
        for i in 1...2{
            textures.append(SKTexture(imageNamed: "e1_idleup_0\(i)"))
        }
        animation = SKAction.animate(with: textures, timePerFrame: 0.4)
        run(SKAction.repeatForever(animation))
    }
    
    func idleLeftAnimation(){
        var textures:[SKTexture] = []
        var animation: SKAction = SKAction()
        for i in 1...2{
            textures.append(SKTexture(imageNamed: "e1_idleleft_0\(i)"))
        }
        animation = SKAction.animate(with: textures, timePerFrame: 0.4)
        run(SKAction.repeatForever(animation))
    }
    
    func idleRightAnimation(){
        var textures:[SKTexture] = []
        var animation: SKAction = SKAction()
        for i in 1...2{
            textures.append(SKTexture(imageNamed: "e1_idleright_0\(i)"))
        }
        animation = SKAction.animate(with: textures, timePerFrame: 0.4)
        run(SKAction.repeatForever(animation))
    }
    
    
    func moveUp(){
        moveAmount += 1
        move(theXAmount: 0, theYAmount: moveDistance, theAnimation: "e1_walkup", face: PlayerFace.up)
        face = PlayerFace.up
    }
    
    func moveDown(){
        moveAmount += 1
        move(theXAmount: 0, theYAmount: -moveDistance, theAnimation: "e1_walkdown", face: PlayerFace.down)
        face = PlayerFace.down
    }
    
    func moveLeft(){
        moveAmount += 1
        move(theXAmount: -moveDistance, theYAmount: 0, theAnimation: "e1_walkleft", face: PlayerFace.left)
        face = PlayerFace.left
    }
    
    func moveRight(){
        moveAmount += 1
        move(theXAmount: moveDistance, theYAmount: 0, theAnimation: "e1_walkright", face: PlayerFace.right)
        face = PlayerFace.right
    }
    
    func move(theXAmount:CGFloat , theYAmount:CGFloat, theAnimation:String, face: PlayerFace)  {
        removeAllActions()
        let wait:SKAction = SKAction.wait(forDuration: 0.05)
        let walkAnimation:SKAction = SKAction(named: theAnimation, duration: moveSpeed )!
        let moveAction:SKAction = SKAction.moveBy(x: theXAmount, y: theYAmount, duration: moveSpeed )
        let group:SKAction = SKAction.group( [ walkAnimation, moveAction ] )
        let finish:SKAction = SKAction.run {
            switch face{
            case PlayerFace.right: self.idleRightAnimation()
            case PlayerFace.left: self.idleLeftAnimation()
            case PlayerFace.up: self.idleUpAnimation()
            case PlayerFace.down: self.idleDownAnimation()
            }
        }
        let seq:SKAction = SKAction.sequence( [wait, group, finish] )
        run(seq)
    }
    
    func attack(){
        var attackAction: SKAction = SKAction()
        switch face{
        case PlayerFace.right:
            attackAction = SKAction(named: "e1_attackright")!
            
        case PlayerFace.left:
            attackAction = SKAction(named: "e1_attackleft")!
           
        case PlayerFace.up:
            attackAction = SKAction(named: "e1_attackup")!
            
        case PlayerFace.down:
            attackAction = SKAction(named: "e1_attackdown")!
            
        }
        
        run(attackAction)
    }
}

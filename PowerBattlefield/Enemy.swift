import Foundation
import SpriteKit

enum EnemyState:Int{
    case attack = 1
    case walk = 2
    case idle = 3
}

class Enemy:SKSpriteNode{
    var moveSpeed:TimeInterval = 0.5
    var moveAmount = 0
    var moveDistance:CGFloat = 50
    var face = PlayerFace.down
    var updateStateTime = 0
    var updateStateSetTime = TimeInterval(0)
    var updateStateSet = false
    var time = TimeInterval(0)
    
    init(texture: SKTexture, color: SKColor, size: CGSize, spawnPos: CGPoint) {
        super.init(texture: texture, color: color, size: size)
        position = CGPoint(x: spawnPos.x, y: spawnPos.y)
        physicsBody = SKPhysicsBody(circleOfRadius: 20)
        physicsBody?.categoryBitMask = BodyType.enemy.rawValue
        physicsBody?.affectedByGravity = false
        physicsBody?.collisionBitMask = BodyType.water.rawValue | BodyType.road.rawValue
        
        idleDownAnimation()
    }
    
    func update(state:Int, face:Int){
        if !updateStateSet{
            updateStateSet = true
            updateStateSetTime = time
            if state == EnemyState.attack.rawValue{
                print("attack")
            }else if state == EnemyState.walk.rawValue{
                if face == PlayerFace.left.rawValue{
                    moveLeft()
                }else if face == PlayerFace.right.rawValue{
                    moveRight()
                }else if face == PlayerFace.up.rawValue{
                    moveUp()
                }else if face == PlayerFace.down.rawValue{
                    moveDown()
                }
            }else if state == EnemyState.idle.rawValue{
                if face == PlayerFace.left.rawValue{
                    idleLeftAnimation()
                }else if face == PlayerFace.right.rawValue{
                    idleRightAnimation()
                }else if face == PlayerFace.up.rawValue{
                    idleUpAnimation()
                }else if face == PlayerFace.down.rawValue{
                    idleDownAnimation()
                }
            }
        }else{
            if Int(time - updateStateSetTime) >= updateStateTime{
                updateStateSet = false
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
}

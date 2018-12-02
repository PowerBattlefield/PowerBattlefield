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
    var face = PlayerFace.right
    var enemyLabel = 1
    var hp = GameEnum.enemyMaxHealth.rawValue
    var range:CGFloat = 100
    var damage = 10
    var updateStateTime = 1
    var stateSet = false
    var stateSetTime = TimeInterval(0)
    var stateAmount = 0
    var exp = 50
    var enemyHPSet = false
    var enemyHPSetTime = TimeInterval(0)
    var burn = TimeInterval(0)
    var burnBeginTime = TimeInterval(0)
    
    init(texture: SKTexture, color: SKColor, size: CGSize, spawnPos: CGPoint) {
        super.init(texture: texture, color: color, size: size)
        position = CGPoint(x: spawnPos.x, y: spawnPos.y)
        physicsBody = SKPhysicsBody(texture: texture, size: size)
        physicsBody?.categoryBitMask = BodyType.enemy.rawValue
        physicsBody?.affectedByGravity = false
        physicsBody?.angularDamping = 0
        physicsBody?.allowsRotation = false
        physicsBody?.linearDamping = 0
        physicsBody?.restitution = 0
        physicsBody?.angularDamping = 0
        physicsBody?.collisionBitMask =  0
        physicsBody?.contactTestBitMask = BodyType.grassOnFire.rawValue | BodyType.swordRain.rawValue
        
        name = "enemy"
        idleDownAnimation()
        
    }
    
    func observeStateChange(roomId: String, thePlayer: Player, otherPlayer1: Player){
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
                self.attack(thePlayer: thePlayer, otherPlayer1: otherPlayer1)
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
    
    func attack(thePlayer: Player, otherPlayer1: Player){
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
        detectAttackedPlayer(player: thePlayer, enemy: self)
        detectAttackedPlayer(player: otherPlayer1, enemy: self)
        run(attackAction)
    }
    
    func detectAttackedPlayer(player: Player, enemy: Enemy){
        let enemyPosAdjust = CGPoint(x: enemy.position.x - 20, y: enemy.position.y + 120)
        var attackedFlag = false
        if face == PlayerFace.right {
            if enemyPosAdjust.x > player.position.x - enemy.range - 50 && enemyPosAdjust.x < player.position.x && abs(player.position.y - enemyPosAdjust.y) < enemy.range/2 + 10{
                print("attacted")
                attackedFlag = true
            }
            
        }else if face == PlayerFace.left {
            if enemyPosAdjust.x < player.position.x + enemy.range + 20 && enemyPosAdjust.x > player.position.x && abs(player.position.y - enemyPosAdjust.y) < enemy.range/2+10{
                print("attacted")
                attackedFlag = true
            }
            
        }else if face == PlayerFace.up {
            
            if enemyPosAdjust.y > player.position.y - enemy.range - 60 && enemyPosAdjust.y < player.position.y && abs(player.position.x - enemyPosAdjust.x) < enemy.range/2 + 15{
                print("attacted")
                attackedFlag = true
            }
            
        }else if face == PlayerFace.down {
            
            if enemyPosAdjust.y < player.position.y + enemy.range - 40 && enemyPosAdjust.y > player.position.y && abs(player.position.x - enemyPosAdjust.x) < enemy.range/2 + 15{
                print("attacted")
                attackedFlag = true
            }
        }
        
        if attackedFlag{
            if player.hp > 0{
                player.damaged(damage: enemy.damage)
            }
            let emitter = SKEmitterNode(fileNamed: "SwordParticle")!
            emitter.position = CGPoint(x: 0, y: 0)
            player.addChild(emitter)
            let wait:SKAction = SKAction.wait(forDuration: 0.5)
            let finish:SKAction = SKAction.run {
                emitter.removeFromParent()
            }
            let seq:SKAction = SKAction.sequence( [wait, finish] )
            run(seq)
        }
    }
    
    func deadAnimation(){
        removeAllActions()
        run(SKAction.sequence([SKAction(named: "e1_dead")!, SKAction.run {
            self.removeFromParent()
            }]))
    }
    
    func damaged(damage: Int, attackedBy: Player){
        if hp > 0{
            hp -= damage
            
            switch face{
            case .down:
                run(SKAction(named: "e1_getattackeddown")!)
                break
            case .left:
                run(SKAction(named: "e1_getattackedleft")!)
                break
            case .right:
                run(SKAction(named: "e1_getattackedright")!)
                break
            case .up:
                run(SKAction(named: "e1_getattackedup")!)
                break
            }
            
            if hp <= 0{
                deadAnimation()
                attackedBy.expGained(exp: self.exp)
            }
        }
    }
}

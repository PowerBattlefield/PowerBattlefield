import Foundation
import SpriteKit
import Firebase

enum GameEnum: Int{
    case playerMaxHealth = 200
    case winExp = 500
}

enum BodyType:UInt32{
    case player1 = 1
    case building = 2
    case movingTotem = 4
    case road = 8
    case water = 16
    case rock = 32
    case grass = 64
    case fireball = 128
    case player2 = 256
    case enemy = 512
    case boat = 1024
    case grassOnFire = 2048
}

enum PlayerState:Int{
    case attack = 1
    case walk = 2
    case idle = 3
}

enum PlayerFace:Int{
    case left = 1
    case right = 2
    case up = 3
    case down = 4
}

enum Damage:Int{
    case fireball = 5
    case sword = 10
}

class Player: SKSpriteNode{
    
    var moveSpeed:TimeInterval = 0.5
    var moveDistance:CGFloat = 75
    var moveAmount = 0
    var attackAmount = 0
    var playerLabel: Int = 1
    var roomId: String = "1"
    var state: PlayerState = PlayerState.idle
    var face: PlayerFace = PlayerFace.down
    var hp:Int = GameEnum.playerMaxHealth.rawValue
    var hold:Bool = false
    var range:CGFloat = 100
    var burn = TimeInterval(0)
    
    var damage = 0
    var otherPlayer1Pos:CGPoint = CGPoint.init()
    var time = TimeInterval(0)
    var exp = 0
    
    
    var refx: DatabaseReference = Database.database().reference()
    var refy: DatabaseReference = Database.database().reference()
    var refMoveRight: DatabaseReference = Database.database().reference()
    var refMoveLeft: DatabaseReference = Database.database().reference()
    var refMoveUp: DatabaseReference = Database.database().reference()
    var refMoveDown: DatabaseReference = Database.database().reference()
    var refAttackRight: DatabaseReference = Database.database().reference()
    var refAttackLeft: DatabaseReference = Database.database().reference()
    var refAttackUp: DatabaseReference = Database.database().reference()
    var refAttackDown: DatabaseReference = Database.database().reference()
    var refAttack: DatabaseReference = Database.database().reference()
    var refPos: DatabaseReference = Database.database().reference()
    var refHP: DatabaseReference = Database.database().reference()
    var refSkill: DatabaseReference = Database.database().reference()
    var refExp: DatabaseReference = Database.database().reference()
    
    func initialize(playerLabel: Int, roomId: String){
        self.playerLabel = playerLabel
        self.roomId = roomId
        self.hp = 1
        setDatabaseReference()
        setPhysicsBody()
        idleDownAnimation()
        
        zPosition = 800
        if playerLabel == 1{
            damage = Damage.sword.rawValue
        }else if playerLabel == 2{
            damage = Damage.fireball.rawValue
        }
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
    
    func idleUpAnimation(){
        var textures:[SKTexture] = []
        var animation: SKAction = SKAction()
        for i in 1...4{
            textures.append(SKTexture(imageNamed: "p\(playerLabel)_idleup_0\(i)"))
        }
        animation = SKAction.animate(with: textures, timePerFrame: 0.4)
        run(SKAction.repeatForever(animation))
    }
    
    func idleLeftAnimation(){
        var textures:[SKTexture] = []
        var animation: SKAction = SKAction()
        for i in 1...4{
            textures.append(SKTexture(imageNamed: "p\(playerLabel)_idleleft_0\(i)"))
        }
        animation = SKAction.animate(with: textures, timePerFrame: 0.4)
        run(SKAction.repeatForever(animation))
    }
    
    func idleRightAnimation(){
        var textures:[SKTexture] = []
        var animation: SKAction = SKAction()
        for i in 1...4{
            textures.append(SKTexture(imageNamed: "p\(playerLabel)_idleright_0\(i)"))
        }
        animation = SKAction.animate(with: textures, timePerFrame: 0.4)
        run(SKAction.repeatForever(animation))
    }
    
    func deadAnimation(){
        removeAllActions()
        run(SKAction(named: "p\(playerLabel)_dead")!)
    }
    
    func setPhysicsBody(){
        if playerLabel == 1{
            self.physicsBody?.categoryBitMask = BodyType.player1.rawValue
            self.physicsBody?.contactTestBitMask = BodyType.player2.rawValue | BodyType.grassOnFire.rawValue
        }
        else{
            self.physicsBody?.categoryBitMask = BodyType.player2.rawValue
            self.physicsBody?.contactTestBitMask = BodyType.player1.rawValue
        }
        self.physicsBody?.contactTestBitMask |= BodyType.building.rawValue | BodyType.water.rawValue | BodyType.fireball.rawValue | BodyType.enemy.rawValue
        self.physicsBody?.collisionBitMask = BodyType.road.rawValue | BodyType.water.rawValue | BodyType.building.rawValue
    }
    
    func setDatabaseReference(){
        refx = Database.database().reference().child(roomId).child("player\(playerLabel)").child("position").child("x")
        refMoveRight = Database.database().reference().child(roomId).child("player\(playerLabel)").child("move").child("right")
        refMoveLeft = Database.database().reference().child(roomId).child("player\(playerLabel)").child("move").child("left")
        refMoveUp = Database.database().reference().child(roomId).child("player\(playerLabel)").child("move").child("up")
        refMoveDown = Database.database().reference().child(roomId).child("player\(playerLabel)").child("move").child("down")
        refy = Database.database().reference().child(roomId).child("player\(playerLabel)").child("position").child("y")
        refAttackRight = Database.database().reference().child(roomId).child("player\(playerLabel)").child("attack").child("right")
        refAttackLeft = Database.database().reference().child(roomId).child("player\(playerLabel)").child("attack").child("left")
        refAttackUp = Database.database().reference().child(roomId).child("player\(playerLabel)").child("attack").child("up")
        refAttackDown = Database.database().reference().child(roomId).child("player\(playerLabel)").child("attack").child("down")
        refAttack = Database.database().reference().child(roomId).child("player\(playerLabel)").child("attack")
        refPos = Database.database().reference().child(roomId).child("player\(playerLabel)").child("position")
        refHP = Database.database().reference().child(roomId).child("player\(playerLabel)").child("hp")
        refSkill = Database.database().reference().child(roomId).child("player\(playerLabel)").child("skill")
        refExp = Database.database().reference().child(roomId).child("player\(playerLabel)").child("exp")
    }
    
    func attack(otherPlayer: Bool){
        var attackAction: SKAction = SKAction()
        switch face{
        case PlayerFace.right:
            attackAction = SKAction(named: "p\(playerLabel)_attackright")!
            if(playerLabel == 1){
                let theWeapon = (self.childNode(withName: "Sword") as? SKSpriteNode)!
                theWeapon.run(SKAction(named: "sword_attackright")!)
                if damage == 15{
                    let effect = self.childNode(withName: "Effect") as! SKSpriteNode
                    effect.run(SKAction(named: "sword_effectright")!)
                }
            }else{
                let fireball = FireBall(texture: SKTexture(imageNamed: "fireball"), color: SKColor.clear, size: CGSize(width: 100, height: 100), playerPos: position)
                if let scene = parent{
                    scene.addChild(fireball)
                }
                fireball.physicsBody?.applyImpulse(CGVector(dx:5, dy:0))
                let wait:SKAction = SKAction.wait(forDuration: 1)
                let finish:SKAction = SKAction.run {
                    fireball.removeFromParent()
                }
                let seq:SKAction = SKAction.sequence( [wait, finish] )
                run(seq)
            }
        case PlayerFace.left:
            attackAction = SKAction(named: "p\(playerLabel)_attackleft")!
            if(playerLabel == 1){
                let theWeapon = (self.childNode(withName: "Sword") as? SKSpriteNode)!
                theWeapon.run(SKAction(named: "sword_attackleft")!)
                if damage == 15{
                    let effect = self.childNode(withName: "Effect") as! SKSpriteNode
                    effect.run(SKAction(named: "sword_effectleft")!)
                }
            }else{
                let fireball = FireBall(texture: SKTexture(imageNamed: "fireball"), color: SKColor.clear, size: CGSize(width: 100, height: 100), playerPos: position)
                if let scene = parent{
                    scene.addChild(fireball)
                }
                fireball.physicsBody?.applyImpulse(CGVector(dx:-5, dy:0))
                let wait:SKAction = SKAction.wait(forDuration: 1)
                let finish:SKAction = SKAction.run {
                    fireball.removeFromParent()
                }
                let seq:SKAction = SKAction.sequence( [wait, finish] )
                run(seq)
            }
        case PlayerFace.up:
            attackAction = SKAction(named: "p\(playerLabel)_attackup")!
            if(playerLabel == 1){
                let theWeapon = (self.childNode(withName: "Sword") as? SKSpriteNode)!
                theWeapon.run(SKAction(named: "sword_attackup")!)
                if damage == 15{
                    let effect = self.childNode(withName: "Effect") as! SKSpriteNode
                    effect.run(SKAction(named: "sword_effectup")!)
                }
            }else{
                let fireball = FireBall(texture: SKTexture(imageNamed: "fireball"), color: SKColor.clear, size: CGSize(width: 100, height: 100), playerPos: position)
                if let scene = parent{
                    scene.addChild(fireball)
                }
                fireball.physicsBody?.applyImpulse(CGVector(dx:0, dy:5))
                let wait:SKAction = SKAction.wait(forDuration: 1)
                let finish:SKAction = SKAction.run {
                    fireball.removeFromParent()
                }
                let seq:SKAction = SKAction.sequence( [wait, finish] )
                run(seq)
            }
        case PlayerFace.down:
            attackAction = SKAction(named: "p\(playerLabel)_attackdown")!
            if(playerLabel == 1){
                let theWeapon = (self.childNode(withName: "Sword") as? SKSpriteNode)!
                theWeapon.run(SKAction(named: "sword_attackdown")!)
                if damage == 15{
                    let effect = self.childNode(withName: "Effect") as! SKSpriteNode
                    effect.run(SKAction(named: "sword_effectdown")!)
                }
            }else{
                let fireball = FireBall(texture: SKTexture(imageNamed: "fireball"), color: SKColor.clear, size: CGSize(width: 100, height: 100), playerPos: position)
                if let scene = parent{
                    scene.addChild(fireball)
                }
                fireball.physicsBody?.applyImpulse(CGVector(dx:0, dy:-5))
                let wait:SKAction = SKAction.wait(forDuration: 1)
                let finish:SKAction = SKAction.run {
                    fireball.removeFromParent()
                }
                let seq:SKAction = SKAction.sequence( [wait, finish] )
                run(seq)
            }
        }
        let finish:SKAction = SKAction.run{
            self.state = PlayerState.idle
        }
        state = PlayerState.attack
        let seq:SKAction = SKAction.sequence( [attackAction, finish] )
        run(seq)
        
        if !otherPlayer {
            attackAmount += 1
            refAttack.setValue(attackAmount)
        }
    }
    
    func moveUp(otherPlayer: Bool){
        if(!otherPlayer){
            moveAmount += 1
            refMoveUp.setValue("\(moveAmount)")
        }
        move(theXAmount: 0, theYAmount: moveDistance, theAnimation: "p\(playerLabel)_walkup", face: PlayerFace.up, otherPlayer: otherPlayer)
        
        face = PlayerFace.up
    }
    
    func moveDown(otherPlayer: Bool){
        if(!otherPlayer){
            moveAmount += 1
            refMoveDown.setValue("\(moveAmount)")
        }
        move(theXAmount: 0, theYAmount: -moveDistance, theAnimation: "p\(playerLabel)_walkdown", face: PlayerFace.down, otherPlayer: otherPlayer)
        
        face = PlayerFace.down
    }
    
    func moveLeft(otherPlayer: Bool){
        if(!otherPlayer){
            moveAmount += 1
            refMoveLeft.setValue("\(moveAmount)")
        }
        move(theXAmount: -moveDistance, theYAmount: 0, theAnimation: "p\(playerLabel)_walkleft", face: PlayerFace.left, otherPlayer: otherPlayer)
        
        face = PlayerFace.left
    }
    
    func moveRight(otherPlayer: Bool){
        if(!otherPlayer){
            moveAmount += 1
            refMoveRight.setValue("\(moveAmount)")
        }
        move(theXAmount: moveDistance, theYAmount: 0, theAnimation: "p\(playerLabel)_walkright", face: PlayerFace.right, otherPlayer: otherPlayer)
        
        face = PlayerFace.right
    }
    
    func move(theXAmount:CGFloat , theYAmount:CGFloat, theAnimation:String, face: PlayerFace, otherPlayer: Bool)  {
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
            if !otherPlayer{
                self.refx.setValue(self.position.x)
                self.refy.setValue(self.position.y)
            }
        }
        let seq:SKAction = SKAction.sequence( [wait, group, finish] )
        run(seq)
    }
    
    func damaged(damage: Int){
        hp -= damage
        switch face{
        case .down:
            run(SKAction(named: "p\(playerLabel)_getattackeddown")!)
            break
        case .left:
            run(SKAction(named: "p\(playerLabel)_getattackedleft")!)
            break
        case .right:
            run(SKAction(named: "p\(playerLabel)_getattackedright")!)
            break
        case .up:
            run(SKAction(named: "p\(playerLabel)_getattackedup")!)
            break
        }
        refHP.setValue(hp)
    }
    
    func expGained(exp: Int){
        self.exp += exp
        refExp.setValue(self.exp)
    }
    
}

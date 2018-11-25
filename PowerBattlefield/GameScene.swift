import SpriteKit
import GameplayKit
import Firebase

class GameScene: SKScene, SKPhysicsContactDelegate {
    var viewController: UIViewController?
    let screenWidth = UIScreen.main.bounds.width
    let screenHeight = UIScreen.main.bounds.height
    var thePlayer:Player = Player()
    var otherPlayer1:Player = Player()
    var theWeapon:SKSpriteNode = SKSpriteNode()
    var moveSpeed:TimeInterval = 1
    var currentPlayer = 1
    var currentPlayerState = 1
    var time = TimeInterval(0)
    
    //get room id from room view
    var roomId: String!
    
    var gameEnd = false
    
    //tile map
    var waterTileMap:SKTileMapNode = SKTileMapNode()
    var rockTileMap:SKTileMapNode = SKTileMapNode()
    var grassTileMap:SKTileMapNode = SKTileMapNode()
    
    // game control button
    var Up_btn:SKSpriteNode = SKSpriteNode()
    var Down_btn:SKSpriteNode = SKSpriteNode()
    var Left_btn:SKSpriteNode = SKSpriteNode()
    var Right_btn:SKSpriteNode = SKSpriteNode()
    var Attack_btn:SKSpriteNode = SKSpriteNode()
    var Quit_btn:SKSpriteNode = SKSpriteNode()
    var Skill_btn:SKSpriteNode = SKSpriteNode()
    
    func setPlayers(){
        if(currentPlayer == 1){
            if let somePlayer = self.childNode(withName: "Player1") as? Player {
                thePlayer = somePlayer
                thePlayer.initialize(playerLabel: 1, roomId: roomId)
                Database.database().reference().child(roomId).child(Auth.auth().currentUser!.uid).setValue(1)
                Skill_btn.texture = SKTexture(image: #imageLiteral(resourceName: "p1_skill"))
            }
            if let somePlayer = self.childNode(withName: "Player2") as? Player {
                otherPlayer1 = somePlayer
                otherPlayer1.initialize(playerLabel: 2, roomId: roomId)
            }
        }else{
            if let somePlayer = self.childNode(withName: "Player2") as? Player {
                thePlayer = somePlayer
                thePlayer.initialize(playerLabel: 2, roomId: roomId)
                Database.database().reference().child(roomId).child(Auth.auth().currentUser!.uid).setValue(2)
            }
            if let somePlayer = self.childNode(withName: "Player1") as? Player {
                otherPlayer1 = somePlayer
                otherPlayer1.initialize(playerLabel: 1, roomId: roomId)
            }
        }
    }
    
    override func willMove(from view: SKView) {
        self.removeAllActions()
        self.removeAllChildren()
    }
    
    override func didMove(to view: SKView) {
        if let id = self.userData?.value(forKey: "roomId") {
            roomId = (id as! String)
        }
        if let number = self.userData?.value(forKey: "playerNumber"){
            currentPlayer = number as! Int
        }
        
        setPlayers()
        Database.database().reference().child(roomId).child("gameIsOn").observe(DataEventType.value){ (snapshot) in
            let gameIsOn = snapshot.value as? Bool ?? false
            if !gameIsOn{
                self.removeAllActions()
                self.removeAllChildren()
                self.removeFromParent()
                self.view?.presentScene(nil)
                self.viewController?.dismiss(animated: false, completion: nil)
                //self.viewController?.performSegue(withIdentifier: "quit", sender: self.viewController)
            }
        }
        self.physicsWorld.contactDelegate = self
        
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        
        // setup camera size
        
        let cameraSize = CGSize(width: CGFloat(screenWidth * 2), height: CGFloat(screenHeight * 2))
        scene?.size = cameraSize
        
        updateCamera()
        
        for node in self.children {
            
            if (node.name == "Building") {
                if (node is SKSpriteNode) {
                    node.physicsBody?.categoryBitMask = BodyType.building.rawValue
                    node.physicsBody?.collisionBitMask = 0
                }
            }
            
            if let aCastle:Castle = node as? Castle {
                aCastle.setUpCastle()
                aCastle.dudesInCastle = 5
            }
            
            if (node.name == "GrassTiles") {
                //let tileMap = node as! SKTileMapNode
                
            }
            if (node.name == "WaterTiles") {
                let tileMap = node as! SKTileMapNode
                giveWaterTilePhysicsBody(tileMap: tileMap)
            }
            
            // game control button
            if (node.name == "Up_btn") {
                Up_btn = node as! SKSpriteNode
                Up_btn.zPosition = 1000
            }
            if (node.name == "Down_btn") {
                Down_btn = node as! SKSpriteNode
                Down_btn.zPosition = 1000
            }
            if (node.name == "Left_btn") {
                Left_btn = node as! SKSpriteNode
                Left_btn.zPosition = 1000
            }
            if (node.name == "Right_btn") {
                Right_btn = node as! SKSpriteNode
                Right_btn.zPosition = 1000
            }
            if (node.name == "Attack_btn") {
                Attack_btn = node as! SKSpriteNode
                Attack_btn.zPosition = 1000
            }
            if (node.name == "Quit_btn") {
                Quit_btn = node as! SKSpriteNode
                Quit_btn.zPosition = 1000
            }
            if (node.name == "Skill_btn") {
                Skill_btn = node as! SKSpriteNode
                Skill_btn.zPosition = 1000
            }
            
        }
        observeOtherPlayerMovements()
    }
    func updateCamera() {
        //normal
        let player_x = thePlayer.position.x - 3 //3
        let player_y = thePlayer.position.y - 40//40
        let x_offset = player_x/screenWidth * 1/2 // 750
        let y_offset = player_y/screenHeight * 1/2 //1334
        
        let tileMap = waterTileMap
        let tileSize = waterTileMap.tileSize
        let halfWidth = CGFloat(tileMap.numberOfColumns) / 2.0 * tileSize.width //960
        let halfHeight = CGFloat(tileMap.numberOfRows) / 2.0 * tileSize.height  //960
        
        let Vbound = (halfHeight - screenHeight) / screenHeight * 1/2 // vertical
        let Hbound = (halfWidth - screenWidth) / screenWidth * 1/2 // horizontal
        
        let oldX = scene?.anchorPoint.x
        let oldY = scene?.anchorPoint.y
        // if X or Y out of bound use old value
        let newX = abs(x_offset) > Hbound ? oldX : 0.5-x_offset
        let newY = abs(y_offset) > Vbound ? oldY : 0.5-y_offset
        scene?.anchorPoint = CGPoint(x: newX!, y: newY!)
        // update control stuff
        updateControll(anchor_x: newX!, anchor_y: newY!, halfWidth: halfWidth, halfHeight: halfHeight)
    }
    func updateControll(anchor_x:CGFloat,anchor_y:CGFloat,halfWidth:CGFloat,halfHeight:CGFloat) {
        // attack and direction size are 200*200
        // each arror = 100*50 (x,y)
        //screenHeight 375.0 screenWidth 667.0
        
        let center_x = (anchor_x-0.5) * (-2 * screenWidth)
        let center_y = (anchor_y-0.5) * (-2 * screenHeight)
        
        
        let attack_x = center_x + screenWidth - 100
        let attack_y = center_y - screenHeight + 100
        let direction_x = center_x - screenWidth + 100 + 5
        let direction_y = center_y - screenHeight + 100 + 5
        let quit_x = center_x + screenWidth - 50
        let quit_y = center_y + screenHeight - 50
        
        
        Attack_btn.position = CGPoint(x: attack_x, y: attack_y)
        Up_btn.position = CGPoint(x: direction_x, y: direction_y+50)
        Down_btn.position = CGPoint(x: direction_x, y: direction_y-50)
        Left_btn.position = CGPoint(x: direction_x-50, y: direction_y)
        Right_btn.position = CGPoint(x: direction_x+50, y: direction_y)
        Quit_btn.position = CGPoint(x: quit_x, y: quit_y)
    }
    
    
    func giveWaterTilePhysicsBody(tileMap: SKTileMapNode) {
        
        let tileSize = tileMap.tileSize
        let halfWidth = CGFloat(tileMap.numberOfColumns) / 2.0 * tileSize.width
        let halfHeight = CGFloat(tileMap.numberOfRows) / 2.0 * tileSize.height
        for col in 0..<tileMap.numberOfColumns {
            for row in 0..<tileMap.numberOfRows {
                let tileDefinition = tileMap.tileDefinition(atColumn: col, row: row)
                let isEdgeTile = tileDefinition?.userData?["isWater"] as? Bool
                
                if (isEdgeTile ?? false) {
                    let x = CGFloat(col) * tileSize.width - halfWidth
                    let y = CGFloat(row) * tileSize.height - halfHeight
                    
                    // translate detail code here, 1111 means left up, right up, left down, right down has a physis body. 1010 means only left up, left down has body.
                    if var detailCode = tileDefinition?.userData?["detail"] as? Int {
                        let arr = [10,100,1000,10000]
                        for i in 0 ..< 4 {
                            if detailCode % arr[i] == arr[i]/10 {
                                detailCode = detailCode - arr[i] / 10
                                var offset_x:CGFloat
                                var offset_y:CGFloat
                                switch i {
                                case 0:
                                    offset_x = tileSize.width/2
                                    offset_y = 0
                                case 1:
                                    offset_x = 0
                                    offset_y = 0
                                case 2:
                                    offset_x = tileSize.width/2
                                    offset_y = tileSize.height/2
                                case 3:
                                    offset_x = 0
                                    offset_y = tileSize.height/2
                                default:
                                    offset_x = 0
                                    offset_y = 0
                                }
                                let rect = CGRect(x: 0, y: 0, width: tileSize.width/2, height: tileSize.height/2)
                                let tileNode = SKShapeNode(rect: rect)
                                tileNode.position = CGPoint(x: x+offset_x, y: y+offset_y)
                                tileNode.fillColor = .clear
                                tileNode.lineWidth = 0
                                let helfSize = CGSize(width: tileSize.width/2, height: tileSize.height/2)
                                tileNode.physicsBody = SKPhysicsBody.init(rectangleOf: helfSize, center: CGPoint(x: tileSize.width / 4.0, y: tileSize.height / 4.0))
                                tileNode.physicsBody?.isDynamic = false
                                tileNode.physicsBody?.collisionBitMask = BodyType.player1.rawValue | BodyType.player2.rawValue
                                tileNode.physicsBody?.categoryBitMask = BodyType.water.rawValue
                                tileMap.addChild(tileNode)
                            }
                        }
                        
                    }
                }
            }
        }
        self.waterTileMap = tileMap
    }
    
    var firstObserve = true
    func observeOtherPlayerMovements(){
        otherPlayer1.refMoveUp.observe(DataEventType.value) { (snapshot) in
            if !self.firstObserve{
                self.otherPlayer1.moveUp(otherPlayer: true)
            }
        }
        otherPlayer1.refMoveDown.observe(DataEventType.value) { (snapshot) in
            if !self.firstObserve{
                self.otherPlayer1.moveDown(otherPlayer: true)
            }
        }
        otherPlayer1.refMoveLeft.observe(DataEventType.value) { (snapshot) in
            if !self.firstObserve{
                self.otherPlayer1.moveLeft(otherPlayer: true)
            }
        }
        otherPlayer1.refMoveRight.observe(DataEventType.value) { (snapshot) in
            if !self.firstObserve{
                self.otherPlayer1.moveRight(otherPlayer: true)
            }
        }
       Database.database().reference().child(roomId).child("player1").child("hp").observe(DataEventType.value) { (snapshot) in
            if !self.firstObserve{
                if let hp = snapshot.value as? Int{
                    if self.thePlayer.playerLabel == 1{
                        self.thePlayer.hp = hp
                    }else{
                        self.otherPlayer1.hp = hp
                    }
                }
            }
        }
        
        Database.database().reference().child(roomId).child("player2").child("hp").observe(DataEventType.value) { (snapshot) in
            if !self.firstObserve{
                if let hp = snapshot.value as? Int{
                    if self.thePlayer.playerLabel == 2{
                        self.thePlayer.hp = hp
                    }else{
                        self.otherPlayer1.hp = hp
                    }
                }
            }
        }
        
        otherPlayer1.refPos.observe(DataEventType.value) { (snapshot) in
            if !self.firstObserve{
                var x = 0
                var y = 0
                for rest in snapshot.children.allObjects as! [DataSnapshot]{
                    if rest.key == "x"{
                        x = (rest.value as! NSNumber).intValue
                    }else{
                        y = (rest.value as! NSNumber).intValue
                    }
                }
                
                self.otherPlayer1.position = CGPoint(x: x, y: y)
            }
        }
        
        otherPlayer1.refAttack.observe(DataEventType.value) { (snapshot) in
           
            if self.firstObserve{
                self.firstObserve = false
            }else{
                self.otherPlayer1.attack(otherPlayer: true)
                if self.otherPlayer1.playerLabel == 1{
                    self.detectAttacked(attacker:self.otherPlayer1, attacked: self.thePlayer)
                }
            }
        }
        
    }
    
    let winner = SKLabelNode(fontNamed: "Chalkduster")
    func endGame(currentTime: TimeInterval){
        gameEnd = true
        if endTime == TimeInterval(0){
            endTime = currentTime
        }
        
        let timeRemain = 11 - Int((currentTime - endTime).truncatingRemainder(dividingBy: 11))
        
        winner.name = "winner"
        winner.fontSize = 65
        winner.fontColor = SKColor.green
        winner.position = CGPoint(x: frame.midX, y: frame.midY + 200)
        if(thePlayer.hp <= 0){
            winner.text = "You Lose! Game ends in \(timeRemain - 1) seconds."
        }else{
            winner.text = "You Win! Game ends in \(timeRemain - 1) seconds."
        }
        if winner.parent == nil{
            addChild(winner)
        }else{
            winner.removeFromParent()
            addChild(winner)
        }
        
        if timeRemain == 1{
            if(thePlayer.hp <= 0){
                Database.database().reference().child(roomId).child("winner").setValue(otherPlayer1.playerLabel)
                Database.database().reference().child(roomId).child("gameIsOn").setValue(false)
            }else{
                Database.database().reference().child(roomId).child("winner").setValue(thePlayer.playerLabel)
                Database.database().reference().child(roomId).child("gameIsOn").setValue(false)
            }
        }
        
    }
    
    var deadAniFlag = false
    var endTime = TimeInterval(0)
    var holdBeginTime:TimeInterval = 0
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        updateCamera()
        time = currentTime
        thePlayer.time = currentTime
        
        if(thePlayer.hp <= 0){
            if !deadAniFlag{
                thePlayer.deadAnimation()
                deadAniFlag = true
            }
            endGame(currentTime: currentTime)
        }
        if(otherPlayer1.hp <= 0){
            if !deadAniFlag{
                otherPlayer1.deadAnimation()
                deadAniFlag = true
            }
            endGame(currentTime: currentTime)
        }
        
        for node in self.children {
            
            if (node.name == "Building") {
                
                if (node.position.y > thePlayer.position.y){
                    
                    node.zPosition = -100
                    
                } else {
                    
                    node.zPosition = 100
                    
                }
            }
        }
        
        if hold{
            thePlayer.hold = true
            if holdBeginTime == 0{
                switch moveDirection{
                case "up":
                    thePlayer.moveUp(otherPlayer: false)
                    break
                case "down":
                    thePlayer.moveDown(otherPlayer: false)
                    break
                case "left":
                    thePlayer.moveLeft(otherPlayer: false)
                    break
                case "right":
                    thePlayer.moveRight(otherPlayer: false)
                    break
                default:
                    break
                }
                holdBeginTime = currentTime
            }
            if currentTime - holdBeginTime > 0.5{
                switch moveDirection{
                case "up":
                    thePlayer.moveUp(otherPlayer: false)
                    break
                case "down":
                    thePlayer.moveDown(otherPlayer: false)
                    break
                case "left":
                    thePlayer.moveLeft(otherPlayer: false)
                    break
                case "right":
                    thePlayer.moveRight(otherPlayer: false)
                    break
                default:
                    break
                }
                holdBeginTime = currentTime
            }
        }else{
            thePlayer.hold = false
            holdBeginTime = 0
        }
    }
    
    func touchDown(atPoint pos : CGPoint) {
        
        /*
         if ( pos.y > 0) {
         //top half touch
         
         } else {
         //bottom half touch
         
         moveDown()
         
         }
         */
        
        
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        
    }
    
    func touchUp(atPoint pos : CGPoint) {
        
    }
    
    func detectAttacked(attacker: Player, attacked: Player){
        var attackedFlag = false
        if attacker.face == PlayerFace.right {
            if attacker.position.x > attacked.position.x - 105 && attacker.position.x < attacked.position.x && abs(attacker.position.y - attacked.position.y) < 60{
                print("attacted")
                attackedFlag = true
                attacked.damaged(damage: attacker.damage)
                switch attacked.face{
                case .down:
                    attacked.run(SKAction(named: "p2_getattackeddown")!)
                    break
                case .left:
                    attacked.run(SKAction(named: "p2_getattackedleft")!)
                    break
                case .right:
                    attacked.run(SKAction(named: "p2_getattackedright")!)
                    break
                case .up:
                    attacked.run(SKAction(named: "p2_getattackedup")!)
                    break
                }
            }
            
        }else if attacker.face == PlayerFace.left {
            if attacker.position.x < attacked.position.x + 105 && attacker.position.x > attacked.position.x && abs(attacker.position.y - attacked.position.y) < 60{
                print("attacted")
                attackedFlag = true
                attacked.damaged(damage: attacker.damage)
                switch attacked.face{
                case .down:
                    attacked.run(SKAction(named: "p2_getattackeddown")!)
                    break
                case .left:
                    attacked.run(SKAction(named: "p2_getattackedleft")!)
                    break
                case .right:
                    attacked.run(SKAction(named: "p2_getattackedright")!)
                    break
                case .up:
                    attacked.run(SKAction(named: "p2_getattackedup")!)
                    break
                }
            }
            
        }else if attacker.face == PlayerFace.up {
            
            if attacker.position.y > attacked.position.y - 100 && attacker.position.y < attacked.position.y && abs(attacker.position.x - attacked.position.x) < 50{
                print("attacted")
                attackedFlag = true
                attacked.damaged(damage: attacker.damage)
                switch attacked.face{
                case .down:
                    attacked.run(SKAction(named: "p2_getattackeddown")!)
                    break
                case .left:
                    attacked.run(SKAction(named: "p2_getattackedleft")!)
                    break
                case .right:
                    attacked.run(SKAction(named: "p2_getattackedright")!)
                    break
                case .up:
                    attacked.run(SKAction(named: "p2_getattackedup")!)
                    break
                }
            }
            
        }else if attacker.face == PlayerFace.down {
            
            if attacker.position.y < attacked.position.y + 100 && attacker.position.y > attacked.position.y && abs(attacker.position.x - attacked.position.x) < 50{
                print("attacted")
                attackedFlag = true
                attacked.damaged(damage: attacker.damage)
                switch attacked.face{
                case .down:
                    attacked.run(SKAction(named: "p2_getattackeddown")!)
                    break
                case .left:
                    attacked.run(SKAction(named: "p2_getattackedleft")!)
                    break
                case .right:
                    attacked.run(SKAction(named: "p2_getattackedright")!)
                    break
                case .up:
                    attacked.run(SKAction(named: "p2_getattackedup")!)
                    break
                }
            }
        }
        
        if attackedFlag{
            let emitter = SKEmitterNode(fileNamed: "SwordParticle")!
            emitter.position = CGPoint(x: 0, y: 0)
            attacked.addChild(emitter)
            let wait:SKAction = SKAction.wait(forDuration: 0.5)
            let finish:SKAction = SKAction.run {
                emitter.removeFromParent()
            }
            let seq:SKAction = SKAction.sequence( [wait, finish] )
            run(seq)
        }
    }
    
    var attackTime = TimeInterval(0)
    var attackTimeFlag = false
    var hold = false
    var moveDirection:String = "stop"
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if(!gameEnd){
            for t in touches {
                self.touchDown(atPoint: t.location(in: self))
                
                let location = t.location(in: self)
                let node = self.atPoint(location)
                if (node.name == "Attack_btn") {
                    if !attackTimeFlag{
                        attackTime = time
                        attackTimeFlag = true
                        thePlayer.attack(otherPlayer: false)
                        if thePlayer.playerLabel == 1{
                            detectAttacked(attacker: thePlayer, attacked: otherPlayer1)
                        }
                        Attack_btn.color = UIColor.black
                        Attack_btn.colorBlendFactor = 1
                        let colorize = SKAction.colorize(with: .white, colorBlendFactor: 1, duration: 1)
                        Attack_btn.run(colorize)
                    }
                    if time - attackTime > 1{
                        attackTimeFlag = false
                    }
                }
                if (node.name == "Up_btn") {
                    hold = true
                    moveDirection = "up"
                }
                if (node.name == "Down_btn") {
                    hold = true
                    moveDirection = "down"
                }
                if (node.name == "Left_btn") {
                    hold = true
                    moveDirection = "left"
                }
                if (node.name == "Right_btn") {
                    hold = true
                    moveDirection = "right"
                }
                if (node.name == "Quit_btn"){
                    Database.database().reference().child(roomId).child("gameIsOn").setValue(false)
                }
                break
            }
        }
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        hold = false
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    
    //MARK: Physics contacts
    func didBegin(_ contact: SKPhysicsContact) {
        var attacked = false
        if (contact.bodyA.categoryBitMask == BodyType.player1.rawValue && contact.bodyB.categoryBitMask == BodyType.fireball.rawValue) {
            contact.bodyB.node?.removeFromParent()
            attacked = true
        } else if (contact.bodyB.categoryBitMask == BodyType.player1.rawValue && contact.bodyA.categoryBitMask == BodyType.fireball.rawValue) {
            contact.bodyA.node?.removeFromParent()
            attacked = true
        }
        if attacked{
            let emitter = SKEmitterNode(fileNamed: "FireballParticle")!
            emitter.position = CGPoint(x: 0, y: 0)
            if thePlayer.playerLabel == 1{
                thePlayer.damaged(damage: otherPlayer1.damage)
                thePlayer.addChild(emitter)
                switch thePlayer.face{
                case .down:
                    thePlayer.run(SKAction(named: "p1_getattackeddown")!)
                    break
                case .left:
                    thePlayer.run(SKAction(named: "p1_getattackedleft")!)
                    break
                case .right:
                    thePlayer.run(SKAction(named: "p1_getattackedright")!)
                    break
                case .up:
                    thePlayer.run(SKAction(named: "p1_getattackedup")!)
                    break
                }
            }else{
                otherPlayer1.damaged(damage: thePlayer.damage)
                otherPlayer1.addChild(emitter)
                switch otherPlayer1.face{
                case .down:
                    otherPlayer1.run(SKAction(named: "p1_getattackeddown")!)
                    break
                case .left:
                    otherPlayer1.run(SKAction(named: "p1_getattackedleft")!)
                    break
                case .right:
                    otherPlayer1.run(SKAction(named: "p1_getattackedright")!)
                    break
                case .up:
                    otherPlayer1.run(SKAction(named: "p1_getattackedup")!)
                    break
                }
            }
            let wait:SKAction = SKAction.wait(forDuration: 0.5)
            let finish:SKAction = SKAction.run {
                emitter.removeFromParent()
            }
            let seq:SKAction = SKAction.sequence( [wait, finish] )
            run(seq)
        }
    }
}

import SpriteKit
import GameplayKit
import Firebase
import AVFoundation

class GameScene: SKScene, SKPhysicsContactDelegate {
    var viewController: GameViewController? = GameViewController()
    let screenWidth = UIScreen.main.bounds.width
    let screenHeight = UIScreen.main.bounds.height
    var thePlayer:Player = Player()
    var otherPlayer1:Player = Player()
    var theWeapon:SKSpriteNode? = SKSpriteNode()
    var moveSpeed:TimeInterval = 1
    var currentPlayer = 1
    var currentPlayerState = 1
    var time = TimeInterval(0)
    var skillIsOn = false
    var skill2IsOn = false
    var skillFlag = true
    var skill2Flag = true
    var enemies: [Enemy] = []
    var fired = false
    var quitGame = false
    var someoneQuit = false
    //get room id from room view
    var roomId: String!
    var gameStart = false
    
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
    var Skill2_btn:SKSpriteNode = SKSpriteNode()
    
    //Health bar
    let playerHealthBar = SKSpriteNode()
    let MaxHealth:CGFloat = CGFloat(GameEnum.playerMaxHealth.rawValue)
    
    // sound
    lazy var sound = SoundManager()
    var audioPlayer: AVAudioPlayer!
    
    func setPlayers(){
        if(currentPlayer == 1){
            if let somePlayer = self.childNode(withName: "Player1") as? Player {
                thePlayer = somePlayer
                thePlayer.initialize(playerLabel: 1, roomId: roomId)
                Database.database().reference().child(roomId).child(Auth.auth().currentUser!.uid).setValue(1)
                Database.database().reference().child(roomId).child("player1").child("skill").setValue(false)
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
                Database.database().reference().child(roomId).child("player1").child("skill").setValue(false)
                otherPlayer1.initialize(playerLabel: 1, roomId: roomId)
            }
        }
        thePlayer.zPosition = 900
    }
    
    override func willMove(from view: SKView) {
        self.removeAllActions()
        self.removeAllChildren()
    }
    
    var enemyNumber = 0
    func spawnEnemy(spawnPos: CGPoint, updateStateTime: Int){
        if enemyNumber <= GameEnum.maxEnemyNumber.rawValue{
            let enemy = Enemy(texture: SKTexture(imageNamed: "e1_idledown_01"), color: SKColor.clear, size: SKTexture(imageNamed: "e1_idledown_01").size(), spawnPos: spawnPos)
            addChild(enemy)
            enemies.append(enemy)
            enemyNumber += 1
            enemy.enemyLabel = enemies.count
            enemy.updateStateTime = updateStateTime
            enemy.observeStateChange(roomId: roomId, thePlayer: thePlayer, otherPlayer1: otherPlayer1)
        }
    }
    
    override func didMove(to view: SKView) {
        if let id = self.userData?.value(forKey: "roomId") {
            roomId = (id as! String)
        }
        if let number = self.userData?.value(forKey: "playerNumber"){
            currentPlayer = number as! Int
        }
        
        setPlayers()
        spawnEnemy(spawnPos: CGPoint(x: -100, y: -100), updateStateTime: Int(arc4random_uniform(3)) + 1)
        spawnEnemy(spawnPos: CGPoint(x: -500, y: -500), updateStateTime: Int(arc4random_uniform(3)) + 1)
        spawnEnemy(spawnPos: CGPoint(x: 100, y: 500), updateStateTime: Int(arc4random_uniform(3)) + 1)
        spawnEnemy(spawnPos: CGPoint(x: 300, y: 500), updateStateTime: Int(arc4random_uniform(3)) + 1)
        spawnEnemy(spawnPos: CGPoint(x: -500, y: 500), updateStateTime: Int(arc4random_uniform(3)) + 1)
        spawnEnemy(spawnPos: CGPoint(x: -600, y: 100), updateStateTime: Int(arc4random_uniform(3)) + 1)
        Database.database().reference().child(roomId).child("gameIsOn").observe(DataEventType.value){ (snapshot) in
            let gameIsOn = snapshot.value as? Bool ?? false
            if !gameIsOn{
                self.sound.stopBGM()
                self.sound.removeFromParent()
                self.removeAllActions()
                self.removeAllChildren()
                self.removeFromParent()
                //self.viewController?.removeFromParent()
                self.view?.presentScene(nil)
                self.view?.removeFromSuperview()
                self.scene?.removeFromParent()
                self.viewController?.dismiss(animated: false, completion: nil)
                //self.viewController?.performSegue(withIdentifier: "quit", sender: self.viewController)
            }
        }
        
        Database.database().reference().child(roomId).child("someoneQuit").observe(DataEventType.value){ (snapshot) in
            self.someoneQuit = snapshot.value as? Bool ?? false
        }
        
        self.physicsWorld.contactDelegate = self
        
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        
        // setup camera size
        
        let cameraSize = CGSize(width: CGFloat(screenWidth * 2), height: CGFloat(screenHeight * 2))
        scene?.size = cameraSize
        
        updateCamera()
        
        //setup health bar
        addChild(playerHealthBar)
        updateHealthBar(value: MaxHealth)
        
        //setup sound node
        addChild(sound)
//        sound = SoundManager()
        sound.playBackGround()
        
        for node in self.children {
            
            if (node.name == "Building") {
                if (node is SKSpriteNode) {
                    node.physicsBody?.categoryBitMask = BodyType.building.rawValue
                    node.physicsBody?.collisionBitMask = 0
                }
            }
            
            if (node.name == "MovingTotem") {
                if (node is SKSpriteNode) {
                    node.physicsBody?.categoryBitMask = BodyType.movingTotem.rawValue
                    node.physicsBody?.collisionBitMask = 0
                }
            }
            
            if (node.name == "Boat") {
                if (node is SKSpriteNode) {
                    node.physicsBody?.categoryBitMask = BodyType.boat.rawValue
                }
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
                if thePlayer.playerLabel == 1{
                    Skill_btn.texture = SKTexture(image: #imageLiteral(resourceName: "p1_skill"))
                }else if thePlayer.playerLabel == 2{
                    Skill_btn.texture = SKTexture(image: #imageLiteral(resourceName: "p2_skill"))
                }
            }
            if (node.name == "Skill2_btn") {
                Skill2_btn = node as! SKSpriteNode
                Skill2_btn.zPosition = 1000
                if thePlayer.playerLabel == 1{
                    Skill2_btn.texture = SKTexture(image: #imageLiteral(resourceName: "p1_skill2"))
                }else if thePlayer.playerLabel == 2{
                    Skill2_btn.texture = SKTexture(image: #imageLiteral(resourceName: "p2_skill"))
                }
            }
            
        }
        observeOtherPlayerMovements()
    }
    func updateHealthBar(value:CGFloat) {
        var hp = value
        if (hp>CGFloat(GameEnum.playerMaxHealth.rawValue)) {
            hp = CGFloat(GameEnum.playerMaxHealth.rawValue)
        } else if (hp<0) {
            hp = 0
        }
        let barSize = CGSize(width: 100, height: 8);
        let fillColor = UIColor(red: 113.0/255, green: 202.0/255, blue: 53.0/255, alpha:1)
        let borderColor = UIColor(red: 35.0/255, green: 28.0/255, blue: 40.0/255, alpha:1)
        // create drawing context
        UIGraphicsBeginImageContextWithOptions(barSize, false, 0)
        let context = UIGraphicsGetCurrentContext()
        // draw the outline for the health bar
        borderColor.setStroke()
        let borderRect = CGRect(origin: CGPoint(x: 0, y: 0), size: barSize)
        context!.stroke(borderRect, width: 1)
        // draw the health bar with a colored rectangle
        fillColor.setFill()
        let barWidth = (barSize.width - 1) * CGFloat(hp) / CGFloat(MaxHealth)
        let barRect = CGRect(x: 0.5, y: 0.5, width: barWidth, height: barSize.height - 1)
        context!.fill(barRect)
        // extract image
        let spriteImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        // set sprite texture and size
        playerHealthBar.texture = SKTexture(image: spriteImage!)
        playerHealthBar.size = barSize
        playerHealthBar.zPosition = 900
        playerHealthBar.position = CGPoint(x: thePlayer.position.x-5, y: thePlayer.position.y+30)
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
        let direction_x = center_x - screenWidth + 140 + 5
        let direction_y = center_y - screenHeight + 150 + 5
        let quit_x = center_x + screenWidth - 50
        let quit_y = center_y + screenHeight - 50
        let skill_x = attack_x + 50
        let skill_y = attack_y + 100
        let skill2_x = attack_x - 150
        let skill2_y = attack_y - 50
        
        Attack_btn.position = CGPoint(x: attack_x, y: attack_y)
        Up_btn.position = CGPoint(x: direction_x, y: direction_y+50)
        Down_btn.position = CGPoint(x: direction_x, y: direction_y-50)
        Left_btn.position = CGPoint(x: direction_x-50, y: direction_y)
        Right_btn.position = CGPoint(x: direction_x+50, y: direction_y)
        Quit_btn.position = CGPoint(x: quit_x, y: quit_y)
        Skill_btn.position = CGPoint(x: skill_x, y: skill_y)
        Skill2_btn.position = CGPoint(x: skill2_x, y: skill2_y)
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
        
        Database.database().reference().child(roomId).child("spawnEnemy").observe(DataEventType.value) { (snapshot) in
           if !self.firstObserve && !self.gameEnd{
                var x = 0
                var y = 0
                var time = 0
                for rest in snapshot.children.allObjects as! [DataSnapshot]{
                    if rest.key == "x"{
                        x = (rest.value as! NSNumber).intValue
                    }else if rest.key == "y"{
                        y = (rest.value as! NSNumber).intValue
                    }else if rest.key == "time"{
                        time = (rest.value as! NSNumber).intValue
                    }
                }
            if self.gameStartTimeSet && Int(self.time - self.gameStartTime) > 10{
                self.spawnEnemy(spawnPos: CGPoint(x: x * 100, y: y * 100), updateStateTime: time)
            }
        }
        }
        
        otherPlayer1.refMoveUp.observe(DataEventType.value) { (snapshot) in
            if !self.firstObserve && !self.gameEnd{
                self.otherPlayer1.moveUp(otherPlayer: true)
            }
        }
        otherPlayer1.refMoveDown.observe(DataEventType.value) { (snapshot) in
            if !self.firstObserve && !self.gameEnd{
                self.otherPlayer1.moveDown(otherPlayer: true)
            }
        }
        otherPlayer1.refMoveLeft.observe(DataEventType.value) { (snapshot) in
            if !self.firstObserve && !self.gameEnd{
                self.otherPlayer1.moveLeft(otherPlayer: true)
            }
        }
        otherPlayer1.refMoveRight.observe(DataEventType.value) { (snapshot) in
            if !self.firstObserve && !self.gameEnd{
                self.otherPlayer1.moveRight(otherPlayer: true)
            }
        }
        
        Database.database().reference().child(roomId).child("player1").child("freeze").observe(DataEventType.value) { (snapshot) in
            if !self.firstObserve && self.thePlayer.playerLabel == 2{
                let ice = self.otherPlayer1.childNode(withName: "Ice") as! SKSpriteNode
                let freeze = snapshot.value as? Bool ?? false
                if freeze{
                    ice.alpha = 1
                }else{
                    ice.alpha = 0
                }
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
        
        Database.database().reference().child(roomId).child("player1").child("exp").observe(DataEventType.value) { (snapshot) in
            if !self.firstObserve{
                if let exp = snapshot.value as? Int{
                    if self.thePlayer.playerLabel == 1{
                        
                        self.thePlayer.exp = exp
                    }else{
                        
                        self.otherPlayer1.exp = exp
                    }
                }
            }
        }
        
        Database.database().reference().child(roomId).child("player2").child("exp").observe(DataEventType.value) { (snapshot) in
            if !self.firstObserve{
                if let exp = snapshot.value as? Int{
                    if self.thePlayer.playerLabel == 2{
                        
                        self.thePlayer.exp = exp
                    }else{
                        
                        self.otherPlayer1.exp = exp
                    }
                }
            }
        }
        
        Database.database().reference().child(roomId).child("player1").child("level").observe(DataEventType.value) { (snapshot) in
            if !self.firstObserve{
                if let level = snapshot.value as? Int{
                    if self.thePlayer.playerLabel == 1{
                        
                        self.thePlayer.level = level
                    }else{
                        
                        self.otherPlayer1.level = level
                    }
                }
            }
        }
        
        Database.database().reference().child(roomId).child("player2").child("level").observe(DataEventType.value) { (snapshot) in
            if !self.firstObserve{
                if let level = snapshot.value as? Int{
                    if self.thePlayer.playerLabel == 2{
                        
                        self.thePlayer.level = level
                    }else{
                        
                        self.otherPlayer1.level = level
                    }
                }
            }
        }
        
        thePlayer.refSkill.observe(DataEventType.value) { (snapshot) in
            if !self.firstObserve && !self.gameEnd{
                let skillIsOn = snapshot.value as? Bool ?? false
                if self.thePlayer.playerLabel == 1{
                    let aura = self.thePlayer.childNode(withName: "Aura") as! SKSpriteNode
                    let effect = self.thePlayer.childNode(withName: "Effect") as! SKSpriteNode
                    if skillIsOn{
                        self.thePlayer.moveSpeed = 0.3
                        self.thePlayer.damage = 15
                        self.thePlayer.range = 150
                        aura.alpha = 1
                        effect.alpha = 1
                        aura.run(SKAction(named: "p1_aura")!)
                    }else if !skillIsOn{
                        aura.removeAllActions()
                        //aura.texture = nil
                        aura.alpha = 0
                        effect.alpha = 0
                        self.thePlayer.moveSpeed = 0.5
                        self.thePlayer.damage = 10
                        self.thePlayer.range = 100
                    }
                }else if self.thePlayer.playerLabel == 2{
                    if skillIsOn{
                        self.addFireOnGrassEmitter(node: self.thePlayer)
                    }
                }
            }
        }
        
        thePlayer.refSkill2.observe(DataEventType.value) { (snapshot) in
            if !self.firstObserve && !self.gameEnd{
                let skill2IsOn = snapshot.value as? Bool ?? false
                if self.thePlayer.playerLabel == 1{
                    if skill2IsOn{
                        self.addSwordRainOnGrassEmitter(node: self.thePlayer)
                    }
                }else if self.thePlayer.playerLabel == 2{
                    if skill2IsOn{
                        self.addSnowOnGrassEmitter(node: self.thePlayer)
                    }
                }
            }
        }
        
        otherPlayer1.refSkill.observe(DataEventType.value) { (snapshot) in
            if !self.firstObserve && !self.gameEnd{
                let skillIsOn = snapshot.value as? Bool ?? false
                if self.otherPlayer1.playerLabel == 1{
                    let aura = self.otherPlayer1.childNode(withName: "Aura") as! SKSpriteNode
                    let effect = self.otherPlayer1.childNode(withName: "Effect") as! SKSpriteNode
                    if skillIsOn{
                        self.otherPlayer1.moveSpeed = 0.3
                        self.otherPlayer1.damage = 15
                        self.otherPlayer1.range = 150
                        aura.alpha = 1
                        effect.alpha = 1
                        aura.run(SKAction(named: "p1_aura")!)
                    }else if !skillIsOn{
                        aura.removeAllActions()
                        //aura.texture = nil
                        aura.alpha = 0
                        effect.alpha = 0
                        self.otherPlayer1.moveSpeed = 0.5
                        self.otherPlayer1.damage = 10
                        self.otherPlayer1.range = 100
                    }
                }else if self.otherPlayer1.playerLabel == 2{
                    if skillIsOn{
                        self.addFireOnGrassEmitter(node: self.otherPlayer1)
                    }
                }
            }
        }
        
        otherPlayer1.refSkill2.observe(DataEventType.value) { (snapshot) in
            if !self.firstObserve && !self.gameEnd{
                let skill2IsOn = snapshot.value as? Bool ?? false
                if self.otherPlayer1.playerLabel == 1{
                    if skill2IsOn{
                        self.addSwordRainOnGrassEmitter(node: self.otherPlayer1)
                    }
                }else if self.otherPlayer1.playerLabel == 2{
                    if skill2IsOn{
                        self.addSnowOnGrassEmitter(node: self.otherPlayer1)
                    }
                }
            }
        }
        
        otherPlayer1.refPos.observe(DataEventType.value) { (snapshot) in
            if !self.firstObserve && !self.gameEnd{
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
            }else if !self.gameEnd{
                self.fired = true
                self.otherPlayer1.attack(otherPlayer: true)
                if self.otherPlayer1.playerLabel == 1{
                    self.detectAttacked(attacker:self.otherPlayer1, attacked: self.thePlayer)
                    for enemy in self.enemies{
                        self.detectAttackedEnemy(attacker: self.otherPlayer1, attacked: enemy)
                    }
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
        
        let timeRemain = 6 - Int((currentTime - endTime).truncatingRemainder(dividingBy: 6))
        
        winner.zPosition = 900
        winner.name = "winner"
        winner.fontSize = 65
        winner.fontColor = UIColor.green
        winner.position = CGPoint(x: frame.midX, y: frame.midY + 200)
        if(otherPlayer1.level < GameEnum.winLevel.rawValue && thePlayer.level < GameEnum.winLevel.rawValue && thePlayer.hp > 0 && otherPlayer1.hp > 0){
            winner.fontSize = 40
            if quitGame{
                winner.text = "You lose because of quitting! Game ends in \(timeRemain - 1) seconds."
            }else{
                winner.text = "You win because other quited! Game ends in \(timeRemain - 1) seconds."
            }
        }
        else if(thePlayer.hp <= 0 || otherPlayer1.level >= 5){
            winner.text = "You Lose! Game ends in \(timeRemain - 1) seconds."
        }
        else{
            winner.text = "You Win! Game ends in \(timeRemain - 1) seconds."
        }
        if winner.parent == nil{
            addChild(winner)
        }else{
            winner.removeFromParent()
            addChild(winner)
        }
        
        if timeRemain == 1{
            if(thePlayer.hp > 0 && otherPlayer1.hp > 0){
                if quitGame{
                    Database.database().reference().child(roomId).child("winner").setValue(otherPlayer1.playerLabel)
                    Database.database().reference().child(roomId).child("gameIsOn").setValue(false)
                }else{
                    Database.database().reference().child(roomId).child("winner").setValue(thePlayer.playerLabel)
                    Database.database().reference().child(roomId).child("gameIsOn").setValue(false)
                }
            }
            else if(thePlayer.hp <= 0){
                Database.database().reference().child(roomId).child("winner").setValue(otherPlayer1.playerLabel)
                Database.database().reference().child(roomId).child("gameIsOn").setValue(false)
            }else{
                Database.database().reference().child(roomId).child("winner").setValue(thePlayer.playerLabel)
                Database.database().reference().child(roomId).child("gameIsOn").setValue(false)
            }
        }
        
    }
    
    let startGameLabel = SKLabelNode(fontNamed: "Chalkduster")
    var startGameLabelRemoved = false
    var startTime = TimeInterval(0)
    func startGame(currentTime: TimeInterval){
        
        if !gameStart{
            
            if startTime == TimeInterval(0){
                startTime = currentTime
            }
            
            let timeRemain = 6 - Int((currentTime - startTime).truncatingRemainder(dividingBy: 6))
            
            startGameLabel.zPosition = 900
            startGameLabel.fontSize = 65
            startGameLabel.fontColor = UIColor.green
            startGameLabel.position = CGPoint(x: frame.midX, y: frame.midY + 200)
            startGameLabel.text = "Game starts in \(timeRemain - 2) seconds."
            if startGameLabel.parent == nil{
                addChild(startGameLabel)
            }else{
                startGameLabel.removeFromParent()
                addChild(startGameLabel)
            }
            if timeRemain == 1{
                gameStart = true
                startGameLabel.removeFromParent()
            }
        }
    }
    
    var deadAniFlag = false
    var endTime = TimeInterval(0)
    var holdBeginTime:TimeInterval = 0
    var skillBeginTime:TimeInterval = 0
    var skill2BeginTime:TimeInterval = 0
    var burnBeginTime:TimeInterval = 0
    var freezeBeginTime:TimeInterval = 0
    var CDFlag:Bool = false
    var CD2Flag:Bool = false
    
    
    var enemySpawned = false
    var enemySpawnTime = TimeInterval(0)
    var gameStartTimeSet = false
    var gameStartTime = TimeInterval(0)
    var enemyFirstRead = true
    
    func detectPlayerLevelUp(){
        thePlayer.checkLevelUp()
        otherPlayer1.checkLevelUp()
        if thePlayer.levelupFlag{
            thePlayer.levelUp()
        }
        if otherPlayer1.levelupFlag{
            otherPlayer1.levelUp()
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        if !gameStartTimeSet{
            gameStartTime = currentTime
            gameStartTimeSet = true
        }
        
        if !gameStart{
            startGame(currentTime: currentTime)
        }
        
        updateCamera()
        updateHealthBar(value: CGFloat(thePlayer.hp))
        if currentPlayer == 1  && gameStart{
            if !enemySpawned{
                enemySpawned = true
                enemySpawnTime = currentTime
                let enemyPosx = Int(arc4random_uniform(11)) - 5
                let enemyPosy = Int(arc4random_uniform(11)) - 5
                let updateTime = Int(arc4random_uniform(3)) + 1
                Database.database().reference().child(roomId).child("spawnEnemy").child("x").setValue(enemyPosx)
                Database.database().reference().child(roomId).child("spawnEnemy").child("y").setValue(enemyPosy)
                Database.database().reference().child(roomId).child("spawnEnemy").child("time").setValue(updateTime)
                
            }else{
                if Int(currentTime - enemySpawnTime) >= GameEnum.updateEnemy.rawValue{
                    enemySpawned = false
                }
            }
            
            var i = 1
            for enemy in enemies{
                if !enemy.enemyHPSet{
                    enemy.enemyHPSet = true
                    Database.database().reference().child(roomId).child("enemy\(i)").child("hp").setValue(enemy.hp)
                    Database.database().reference().child(roomId).child("enemy\(i)").child("pos").child("x").setValue(enemy.position.x)
                    Database.database().reference().child(roomId).child("enemy\(i)").child("pos").child("y").setValue(enemy.position.y)
                    enemy.enemyHPSetTime = currentTime
                    
                }else{
                    if Int(currentTime - enemy.enemyHPSetTime) >= 1{
                        enemy.enemyHPSet = false
                    }
                }
                if(enemy.hp > 0){
                    if !enemy.stateSet{
                        let state = Int(arc4random_uniform(3)) + 1
                        let face = Int(arc4random_uniform(4)) + 1
                        Database.database().reference().child(roomId).child("enemy\(i)").child("state").setValue(state)
                        Database.database().reference().child(roomId).child("enemy\(i)").child("face").setValue(face)
                        Database.database().reference().child(roomId).child("enemy\(i)").child("change").setValue(enemy.stateAmount)
                        enemy.stateAmount += 1
                        enemy.stateAmount += 1
                        enemy.stateSet = true
                        enemy.stateSetTime = currentTime
                        
                    }else{
                        if Int(currentTime - enemy.stateSetTime) >= enemy.updateStateTime{
                            enemy.stateSet = false
                        }
                        
                    }
                }else{
                    if enemy.parent != nil && !enemy.dead{
                        enemy.dead = true
                        enemy.deadAnimation()
                        enemyNumber -= 1
                    }
                }
                i += 1
            }
            
        }else if gameStart{
            var i = 1
            for enemy in enemies{
                if(enemy.hp > 0){
                    if !enemy.enemyHPGet{
                         print("3")
                        enemy.enemyHPGet = true
                        if enemy.enemyFirstRead{
                            enemy.enemyFirstRead = false
                        }
                        else{
                            enemy.enemyHPGetTime = currentTime
                            Database.database().reference().child(roomId).child("enemy\(i)").child("pos").observeSingleEvent(of: .value, with: { (snapshot) in
                                print("pos")
                                if !self.gameEnd{
                                    var x = 0
                                    var y = 0
                                    for rest in snapshot.children.allObjects as! [DataSnapshot]{
                                        if rest.key == "x"{
                                            x = (rest.value as! NSNumber).intValue
                                        }else{
                                            y = (rest.value as! NSNumber).intValue
                                        }
                                    }
                                    enemy.position = CGPoint(x: x, y: y)
                                }
                            })
                            Database.database().reference().child(roomId).child("enemy\(i)").child("hp").observeSingleEvent(of: .value, with: { (snapshot) in
                                enemy.hp = snapshot.value as? Int ?? 100
                                print("hp")
                                if(enemy.hp <= 0){
                                    if enemy.parent != nil && !enemy.dead{
                                        enemy.dead = true
                                        enemy.deadAnimation()
                                        self.enemyNumber -= 1
                                    }
                                }else{
                                    if enemy.parent == nil{
                                        self.addChild(enemy)
                                    }
                                }
                            })
                        }
                    }else{
                        if Int(currentTime - enemy.enemyHPGetTime) >= 1{
                            enemy.enemyHPGet = false
                        }
                    }
                }else{
                    if enemy.parent != nil && !enemy.dead{
                        enemy.dead = true
                        enemy.deadAnimation()
                        enemyNumber -= 1
                    }
                }
                i += 1
            }
        }
        
        time = currentTime
        thePlayer.time = currentTime
        otherPlayer1.time = currentTime
        
        detectPlayerLevelUp()
        
        if someoneQuit{
            endGame(currentTime: currentTime)
        }else if(thePlayer.hp <= 0){
            if !deadAniFlag{
                thePlayer.deadAnimation()
                deadAniFlag = true
            }
            endGame(currentTime: currentTime)
        }
        else if(otherPlayer1.hp <= 0){
            if !deadAniFlag{
                otherPlayer1.deadAnimation()
                deadAniFlag = true
            }
            endGame(currentTime: currentTime)
        }else if thePlayer.level >= GameEnum.winLevel.rawValue{
            endGame(currentTime: currentTime)
        }else if otherPlayer1.level >= GameEnum.winLevel.rawValue{
            endGame(currentTime: currentTime)
        }
        
        if hold && !gameEnd && gameStart && thePlayer.freeze != 1{
            thePlayer.hold = true
            if holdBeginTime == 0{
                thePlayer.isInSnow = false
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
            if currentTime - holdBeginTime > Double(thePlayer.moveSpeed){
                thePlayer.isInSnow = false
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
        
        if(thePlayer.playerLabel == 1){
            if thePlayer.isInSnow{
                if freezeBeginTime == 0{
                    freezeBeginTime = currentTime
                }
                if thePlayer.freeze < 1 && currentTime - freezeBeginTime > 0.5{
                    freezeBeginTime = currentTime
                    thePlayer.freeze += 0.5
                }
                else if thePlayer.freeze == 1{
                    let freeze = thePlayer.childNode(withName: "Ice") as! SKSpriteNode
                    freeze.alpha = 1
                    Database.database().reference().child(roomId).child("player1").child("freeze").setValue(true)
                    if currentTime - freezeBeginTime > 5{
                        thePlayer.freeze = 0
                        thePlayer.isInSnow = false
                        freezeBeginTime = 0
                        thePlayer.moveSpeed = 0.5
                        Database.database().reference().child(roomId).child("player1").child("hp").setValue(thePlayer.hp-10)
                        Database.database().reference().child(roomId).child("player1").child("freeze").setValue(false)
                        freeze.alpha = 0
                    }
                }
            }else if !skillIsOn{
                thePlayer.moveSpeed = 0.5
            }
            if thePlayer.burn != 0{
                if thePlayer.burn == 5 && burnBeginTime == 0{
                    burnBeginTime = currentTime
                }
                if currentTime - burnBeginTime > 0.5{
                    burnBeginTime = currentTime
                    thePlayer.burn -= 0.5
                    thePlayer.damaged(damage: 10)
                }
            }else if burnBeginTime != 0{
                burnBeginTime = 0
                thePlayer.moveSpeed = 0.5
                let child = thePlayer.childNode(withName: "Fire") as! SKSpriteNode
                child.removeAllChildren()
            }
            if skillIsOn{
                if thePlayer.burn == 0{
                    thePlayer.moveSpeed = 0.3
                }
                let label = Skill_btn.childNode(withName: "SkillTime") as! SKLabelNode
                if skillBeginTime == 0{
                    skillBeginTime = currentTime
                }
                if currentTime - skillBeginTime <= 20{
                    let duration = Int(21 - currentTime + skillBeginTime)
                    label.fontColor = UIColor.black
                    label.text = String(duration)
                }else if currentTime - skillBeginTime > 20{
                    Database.database().reference().child(roomId).child("player\(thePlayer.playerLabel)").child("skill").setValue(false)
                    skillIsOn = false
                    CDFlag = true
                    if thePlayer.burn == 0{
                        thePlayer.moveSpeed = 0.5
                    }
                }
            }else{
                if skillBeginTime != 0{
                    let label = Skill_btn.childNode(withName: "SkillTime") as! SKLabelNode
                    if currentTime - skillBeginTime <= 40{
                        let coolDown = Int(41 - currentTime + skillBeginTime)
                        label.fontColor = UIColor.white
                        label.text = String(coolDown)
                        if CDFlag{
                            Skill_btn.color = UIColor.black
                            Skill_btn.colorBlendFactor = 1
                            let colorize = SKAction.colorize(with: .white, colorBlendFactor: 1, duration: 20)
                            Skill_btn.run(colorize)
                            CDFlag = false
                        }
                    }else if currentTime - skillBeginTime > 40{
                        label.text = ""
                        skillFlag = true
                        skillBeginTime = 0
                    }
                }
            }
            if skill2IsOn{
                if skill2BeginTime == 0{
                    skill2BeginTime = currentTime
                }
                Database.database().reference().child(roomId).child("player\(thePlayer.playerLabel)").child("skill2").setValue(false)
                skill2IsOn = false
                CD2Flag = true
            }else{
                if skill2BeginTime != 0{
                    let label = Skill2_btn.childNode(withName: "SkillTime") as! SKLabelNode
                    if currentTime - skill2BeginTime <= 20{
                        let coolDown = Int(21 - currentTime + skill2BeginTime)
                        label.fontColor = UIColor.white
                        label.text = String(coolDown)
                        if CD2Flag{
                            Skill2_btn.color = UIColor.black
                            Skill2_btn.colorBlendFactor = 1
                            let colorize = SKAction.colorize(with: .white, colorBlendFactor: 1, duration: 20)
                            Skill2_btn.run(colorize)
                            CD2Flag = false
                        }
                    }else if currentTime - skill2BeginTime > 20{
                        label.text = ""
                        skill2Flag = true
                        skill2BeginTime = 0
                    }
                }
            }
        }else if(thePlayer.playerLabel == 2){
            if otherPlayer1.burn != 0{
                if otherPlayer1.burn == 5 && burnBeginTime == 0{
                    burnBeginTime = currentTime
                }
                if currentTime - burnBeginTime > 0.5{
                    burnBeginTime = currentTime
                    otherPlayer1.burn -= 0.5
                }
            }else if burnBeginTime != 0{
                burnBeginTime = 0
                otherPlayer1.moveSpeed = 0.5
                let child = otherPlayer1.childNode(withName: "Fire") as! SKSpriteNode
                child.removeAllChildren()
            }
            if skillIsOn{
                let label = Skill_btn.childNode(withName: "SkillTime") as! SKLabelNode
                if skillBeginTime == 0{
                    skillBeginTime = currentTime
                }
                if currentTime - skillBeginTime <= 5{
                    let duration = Int(6 - currentTime + skillBeginTime)
                    label.fontColor = UIColor.black
                    label.text = String(duration)
                }else if currentTime - skillBeginTime > 5{
                    Database.database().reference().child(roomId).child("player\(thePlayer.playerLabel)").child("skill").setValue(false)
                    skillIsOn = false
                    CDFlag = true
                }
            }else{
                if skillBeginTime != 0{
                    let label = Skill_btn.childNode(withName: "SkillTime") as! SKLabelNode
                    if currentTime - skillBeginTime <= 15{
                        let coolDown = Int(16 - currentTime + skillBeginTime)
                        label.fontColor = UIColor.white
                        label.text = String(coolDown)
                        if CDFlag{
                            Skill_btn.color = UIColor.black
                            Skill_btn.colorBlendFactor = 1
                            let colorize = SKAction.colorize(with: .white, colorBlendFactor: 1, duration: 10)
                            Skill_btn.run(colorize)
                            CDFlag = false
                        }
                    }else if currentTime - skillBeginTime > 15{
                        label.text = ""
                        skillFlag = true
                        skillBeginTime = 0
                    }
                }
            }
            if skill2IsOn{
                let label = Skill2_btn.childNode(withName: "SkillTime") as! SKLabelNode
                if skill2BeginTime == 0{
                    skill2BeginTime = currentTime
                }
                if currentTime - skill2BeginTime <= 5{
                    let duration = Int(6 - currentTime + skill2BeginTime)
                    label.fontColor = UIColor.black
                    label.text = String(duration)
                }else if currentTime - skill2BeginTime > 5{
                    Database.database().reference().child(roomId).child("player\(thePlayer.playerLabel)").child("skill2").setValue(false)
                    skill2IsOn = false
                    CD2Flag = true
                }
            }else{
                if skill2BeginTime != 0{
                    let label = Skill2_btn.childNode(withName: "SkillTime") as! SKLabelNode
                    if currentTime - skill2BeginTime <= 20{
                        let coolDown = Int(21 - currentTime + skill2BeginTime)
                        label.fontColor = UIColor.white
                        label.text = String(coolDown)
                        if CD2Flag{
                            Skill2_btn.color = UIColor.black
                            Skill2_btn.colorBlendFactor = 1
                            let colorize = SKAction.colorize(with: .white, colorBlendFactor: 1, duration: 15)
                            Skill2_btn.run(colorize)
                            CD2Flag = false
                        }
                    }else if currentTime - skill2BeginTime > 20{
                        label.text = ""
                        skill2Flag = true
                        skill2BeginTime = 0
                    }
                }
            }
        }
        for enemy in enemies{
            if enemy.burn != 0{
                if enemy.burn == 5 && enemy.burnBeginTime == 0{
                    enemy.burnBeginTime = currentTime
                }
                if currentTime - enemy.burnBeginTime > 0.5{
                    enemy.burnBeginTime = currentTime
                    enemy.burn -= 0.5
                    if thePlayer.playerLabel == 2{
                        enemy.damaged(damage: 6, attackedBy: thePlayer)
                    }else{
                        enemy.damaged(damage: 6, attackedBy: otherPlayer1)
                    }
                }
            }else if enemy.burnBeginTime != 0{
                enemy.burnBeginTime = 0
                enemy.removeAllChildren()
            }
        }
        
    }
    
    func detectAttacked(attacker: Player, attacked: Player){
        var attackedFlag = false
        if attacker.face == PlayerFace.right {
            if attacker.position.x > attacked.position.x - attacker.range - 5 && attacker.position.x < attacked.position.x && abs(attacker.position.y - attacked.position.y) < attacker.range/2 + 10{
                print("attacted")
                attackedFlag = true
                attacked.damaged(damage: attacker.damage)
            }
            
        }else if attacker.face == PlayerFace.left {
            if attacker.position.x < attacked.position.x + attacker.range + 5 && attacker.position.x > attacked.position.x && abs(attacker.position.y - attacked.position.y) < attacker.range/2 + 10{
                print("attacted")
                attackedFlag = true
                attacked.damaged(damage: attacker.damage)
            }
            
        }else if attacker.face == PlayerFace.up {
            
            if attacker.position.y > attacked.position.y - attacker.range && attacker.position.y < attacked.position.y && abs(attacker.position.x - attacked.position.x) < attacker.range/2{
                print("attacted")
                attackedFlag = true
                attacked.damaged(damage: attacker.damage)
            }
            
        }else if attacker.face == PlayerFace.down {
            
            if attacker.position.y < attacked.position.y + attacker.range && attacker.position.y > attacked.position.y && abs(attacker.position.x - attacked.position.x) < attacker.range/2{
                print("attacted")
                attackedFlag = true
                attacked.damaged(damage: attacker.damage)
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
    
    func detectAttackedEnemy(attacker: Player, attacked: Enemy){
        let enemyPosAdjust = CGPoint(x: attacked.position.x - 20, y: attacked.position.y + 120)
        var attackedFlag = false
        if attacker.face == PlayerFace.right {
            if attacker.position.x > enemyPosAdjust.x - attacker.range - 35 && attacker.position.x < enemyPosAdjust.x && abs(attacker.position.y - enemyPosAdjust.y) < attacker.range/2 + 70{
                print("attacted")
                attackedFlag = true
                attacked.damaged(damage: attacker.damage, attackedBy: attacker)
            }
            
        }else if attacker.face == PlayerFace.left {
            if attacker.position.x < enemyPosAdjust.x + attacker.range + 60 && attacker.position.x > enemyPosAdjust.x && abs(attacker.position.y - enemyPosAdjust.y) < attacker.range/2 + 70{
                print("attacted")
                attackedFlag = true
                attacked.damaged(damage: attacker.damage, attackedBy: attacker)
            }
            
        }else if attacker.face == PlayerFace.up {
            
            if attacker.position.y > enemyPosAdjust.y - attacker.range && attacker.position.y < enemyPosAdjust.y && abs(attacker.position.x - enemyPosAdjust.x) < attacker.range/2 + 45{
                print("attacted")
                attackedFlag = true
                attacked.damaged(damage: attacker.damage, attackedBy: attacker)
            }
            
        }else if attacker.face == PlayerFace.down {
            
            if attacker.position.y < enemyPosAdjust.y + attacker.range && attacker.position.y > enemyPosAdjust.y && abs(attacker.position.x - enemyPosAdjust.x) < attacker.range/2 + 45{
                print("attacted")
                attackedFlag = true
                attacked.damaged(damage: attacker.damage, attackedBy: attacker)
            }
        }
        
        if attackedFlag{
            let emitter = SKEmitterNode(fileNamed: "SwordParticle")!
            emitter.position = CGPoint(x: -20, y: 120)
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
        if !gameEnd && gameStart && thePlayer.freeze != 1{
            for t in touches {
                
                let location = t.location(in: self)
                let node = self.atPoint(location)
                if (node.name == "Attack_btn") {
                    if !attackTimeFlag{
                        sound.playAudio(musicName: "attack_sword01")
                        attackTime = time
                        attackTimeFlag = true
                        thePlayer.attack(otherPlayer: false)
                        fired = true
                        if thePlayer.playerLabel == 1{
                            detectAttacked(attacker: thePlayer, attacked: otherPlayer1)
                            for enemy in enemies{
                                detectAttackedEnemy(attacker: thePlayer, attacked: enemy)
                            }
                            
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
//                    Database.database().reference().child(roomId).child("gameIsOn").setValue(false)
//                    self.viewController?.dismiss(animated: false, completion: nil)
                    quitGame = true
                    Database.database().reference().child(roomId).child("someoneQuit").setValue(true)
                }
                if (node.name == "Skill_btn"){
                    if skillFlag{
                        Database.database().reference().child(roomId).child("player\(thePlayer.playerLabel)").child("skill").setValue(true)
                        skillIsOn = true
                        skillFlag = false
                        sound.playAudio(musicName: "attack04")
                    }
                }
                if (node.name == "Skill2_btn"){
                    if skill2Flag{
                        Database.database().reference().child(roomId).child("player\(thePlayer.playerLabel)").child("skill2").setValue(true)
                        skill2IsOn = true
                        skill2Flag = false
                        sound.playAudio(musicName: "attack01")
                    }
                }
                break
                
            }
        }
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        hold = false
        
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    
    //MARK: Physics contacts
    func didBegin(_ contact: SKPhysicsContact) {
        checkPlayerAttacked(contact)
        checkBuildingAttacked(contact)
        checkEnemyAttacked(contact)
        checkPlayerBurned(contact)
        checkPlayerSword(contact)
        checkPlayerFreezed(contact)
    }
    
    func checkPlayerAttacked(_ contact: SKPhysicsContact){
        var attacked = false
        if (contact.bodyA.categoryBitMask == BodyType.player1.rawValue && contact.bodyB.categoryBitMask == BodyType.fireball.rawValue) {
            contact.bodyB.node?.removeFromParent()
            attacked = true
        } else if (contact.bodyB.categoryBitMask == BodyType.player1.rawValue && contact.bodyA.categoryBitMask == BodyType.fireball.rawValue) {
            contact.bodyA.node?.removeFromParent()
            attacked = true
        }
        if attacked{
            if thePlayer.playerLabel == 1{
                thePlayer.damaged(damage: otherPlayer1.damage)
                addFireballEmitter(node:thePlayer)
            }else{
                addFireballEmitter(node:otherPlayer1)
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
        }
    }
    
    func checkBuildingAttacked(_ contact: SKPhysicsContact){
        if (contact.bodyB.categoryBitMask == BodyType.boat.rawValue && contact.bodyA.categoryBitMask == BodyType.fireball.rawValue) {
            contact.bodyA.node?.removeFromParent()
            addFireballEmitter(node: contact.bodyB.node!)
        } else if (contact.bodyB.categoryBitMask == BodyType.fireball.rawValue && contact.bodyA.categoryBitMask == BodyType.boat.rawValue) {
            contact.bodyB.node?.removeFromParent()
            addFireballEmitter(node: contact.bodyA.node!)
        } else if (contact.bodyB.categoryBitMask == BodyType.movingTotem.rawValue && contact.bodyA.categoryBitMask == BodyType.fireball.rawValue) {
            contact.bodyA.node?.removeFromParent()
            addFireballEmitter(node: contact.bodyB.node!)
        } else if (contact.bodyB.categoryBitMask == BodyType.fireball.rawValue && contact.bodyA.categoryBitMask == BodyType.movingTotem.rawValue) {
            contact.bodyB.node?.removeFromParent()
            addFireballEmitter(node: contact.bodyA.node!)
        }else if (contact.bodyB.categoryBitMask == BodyType.building.rawValue && contact.bodyA.categoryBitMask == BodyType.fireball.rawValue) {
            contact.bodyA.node?.removeFromParent()
            addFireballEmitter(node: contact.bodyB.node!)
        } else if (contact.bodyB.categoryBitMask == BodyType.fireball.rawValue && contact.bodyA.categoryBitMask == BodyType.building.rawValue) {
            contact.bodyB.node?.removeFromParent()
            addFireballEmitter(node: contact.bodyA.node!)
        }
    }
    
    func checkEnemyAttacked(_ contact: SKPhysicsContact){
        if(fired){
            if (contact.bodyA.categoryBitMask == BodyType.enemy.rawValue && contact.bodyB.categoryBitMask == BodyType.fireball.rawValue) {
                contact.bodyB.node?.removeFromParent()
                fired = false
                addFireballEmitter(node: contact.bodyA.node!)
                (contact.bodyA.node as! Enemy).damaged(damage:Damage.fireball.rawValue, attackedBy: thePlayer.playerLabel == 2 ? thePlayer : otherPlayer1)
            }
        }
    }
    
    func checkPlayerBurned(_ contact: SKPhysicsContact){
        if (contact.bodyA.categoryBitMask == BodyType.player1.rawValue && contact.bodyB.categoryBitMask == BodyType.grassOnFire.rawValue) {
            addFireOnPlayerEmitter(node: contact.bodyA.node!)
        } else if (contact.bodyB.categoryBitMask == BodyType.player1.rawValue && contact.bodyA.categoryBitMask == BodyType.grassOnFire.rawValue) {
            addFireOnPlayerEmitter(node: contact.bodyB.node!)
        }
        if (contact.bodyA.categoryBitMask == BodyType.enemy.rawValue && contact.bodyB.categoryBitMask == BodyType.grassOnFire.rawValue) {
            addFireOnPlayerEmitter(node: contact.bodyA.node!)
        } else if (contact.bodyB.categoryBitMask == BodyType.enemy.rawValue && contact.bodyA.categoryBitMask == BodyType.grassOnFire.rawValue) {
            addFireOnPlayerEmitter(node: contact.bodyB.node!)
        }
    }
    
    func checkPlayerFreezed(_ contact: SKPhysicsContact){
        if (contact.bodyA.categoryBitMask == BodyType.player1.rawValue && contact.bodyB.categoryBitMask == BodyType.snowFlake.rawValue) {
            if let player = contact.bodyA.node as? Player{
                player.isInSnow = true
                player.moveSpeed = 0.75
            }
        } else if (contact.bodyB.categoryBitMask == BodyType.player1.rawValue && contact.bodyA.categoryBitMask == BodyType.snowFlake.rawValue) {
            if let player = contact.bodyA.node as? Player{
                player.isInSnow = true
                player.moveSpeed = 0.75
            }
        }
        if (contact.bodyA.categoryBitMask == BodyType.enemy.rawValue && contact.bodyB.categoryBitMask == BodyType.snowFlake.rawValue) {
            //addFireOnPlayerEmitter(node: contact.bodyA.node!)
        } else if (contact.bodyB.categoryBitMask == BodyType.enemy.rawValue && contact.bodyA.categoryBitMask == BodyType.snowFlake.rawValue) {
            //addFireOnPlayerEmitter(node: contact.bodyB.node!)
        }
    }
    
    func checkPlayerSword(_ contact: SKPhysicsContact){
        if (contact.bodyA.categoryBitMask == BodyType.player2.rawValue && contact.bodyB.categoryBitMask == BodyType.swordRain.rawValue) {
            let emitter = SKEmitterNode(fileNamed: "SwordParticle")!
            emitter.position = CGPoint(x: 0, y: 0)
            contact.bodyA.node?.addChild(emitter)
            let wait:SKAction = SKAction.wait(forDuration: 0.5)
            let finish:SKAction = SKAction.run {
                emitter.removeFromParent()
            }
            let seq:SKAction = SKAction.sequence( [wait, finish] )
            run(seq)
            if thePlayer.playerLabel == 1{
                otherPlayer1.damaged(damage: 1)
                
            }else{
                switch thePlayer.face{
                case .down:
                    thePlayer.run(SKAction(named: "p2_getattackeddown")!)
                    break
                case .left:
                    thePlayer.run(SKAction(named: "p2_getattackedleft")!)
                    break
                case .right:
                    thePlayer.run(SKAction(named: "p2_getattackedright")!)
                    break
                case .up:
                    thePlayer.run(SKAction(named: "p2_getattackedup")!)
                    break
                }
            }
        }else if (contact.bodyB.categoryBitMask == BodyType.player2.rawValue && contact.bodyA.categoryBitMask == BodyType.swordRain.rawValue) {
            let emitter = SKEmitterNode(fileNamed: "SwordParticle")!
            emitter.position = CGPoint(x: 0, y: 0)
            contact.bodyA.node?.addChild(emitter)
            let wait:SKAction = SKAction.wait(forDuration: 0.5)
            let finish:SKAction = SKAction.run {
                emitter.removeFromParent()
            }
            let seq:SKAction = SKAction.sequence( [wait, finish] )
            run(seq)
            if thePlayer.playerLabel == 1{
                otherPlayer1.damaged(damage: 1)
            }else{
                switch thePlayer.face{
                case .down:
                    thePlayer.run(SKAction(named: "p2_getattackeddown")!)
                    break
                case .left:
                    thePlayer.run(SKAction(named: "p2_getattackedleft")!)
                    break
                case .right:
                    thePlayer.run(SKAction(named: "p2_getattackedright")!)
                    break
                case .up:
                    thePlayer.run(SKAction(named: "p2_getattackedup")!)
                    break
                }
            }
        }
        if (contact.bodyA.categoryBitMask == BodyType.enemy.rawValue && contact.bodyB.categoryBitMask == BodyType.swordRain.rawValue) {
            if thePlayer.playerLabel == 1{
                if let enemy = contact.bodyA.node as? Enemy{
                    enemy.damaged(damage: 1, attackedBy: thePlayer)
                }
            }else{
                if let enemy = contact.bodyA.node as? Enemy{
                    enemy.damaged(damage: 1, attackedBy: otherPlayer1)
                }
            }
        } else if (contact.bodyB.categoryBitMask == BodyType.enemy.rawValue && contact.bodyA.categoryBitMask == BodyType.swordRain.rawValue) {
            if thePlayer.playerLabel == 1{
                if let enemy = contact.bodyB.node as? Enemy{
                    enemy.damaged(damage: 1, attackedBy: thePlayer)
                }
            }else{
                if let enemy = contact.bodyB.node as? Enemy{
                    enemy.damaged(damage: 1, attackedBy: otherPlayer1)
                }
            }
        }
    }
    
    func addFireballEmitter(node:SKNode){
        let emitter = SKEmitterNode(fileNamed: "FireballParticle")!
        if node.name == "enemy"{
            emitter.position = CGPoint(x: -20, y: 120)
        }else{
            emitter.position = CGPoint(x: 0, y: 0)
        }
        node.addChild(emitter)
        let wait:SKAction = SKAction.wait(forDuration: 0.5)
        let finish:SKAction = SKAction.run {
            emitter.removeFromParent()
        }
        let seq:SKAction = SKAction.sequence( [wait, finish] )
        run(seq)
    }
    
    func addFireOnPlayerEmitter(node:SKNode){
        if let player = node as? Player{
            if(player.burn < 5){
                let child = player.childNode(withName: "Fire") as! SKSpriteNode
                let emitter = SKEmitterNode(fileNamed: "FireOnPlayer")!
                emitter.position = CGPoint(x: -5, y: -80)
                child.addChild(emitter)
                player.burn = 5
                player.moveSpeed = 0.75
            }
        }
        if let enemy = node as? Enemy{
            if(enemy.burn < 5){
                let emitter = SKEmitterNode(fileNamed: "FireOnPlayer")!
                emitter.position = CGPoint(x: -20, y: 120)
                enemy.addChild(emitter)
                enemy.burn = 5
            }
        }
    }
    func addFireOnGrassEmitter(node:SKNode){
        if let player = node as? Player{
            var attackAction = SKAction()
            var x:CGFloat = 0, y:CGFloat = 0
            switch player.face{
            case .down:
                attackAction = SKAction(named: "p\(player.playerLabel)_attackdown")!
                player.run(attackAction)
                x = 0; y = -1
                break
            case .left:
                attackAction = SKAction(named: "p\(player.playerLabel)_attackleft")!
                player.run(attackAction)
                x = -1;y = 0
                break
            case .right:
                attackAction = SKAction(named: "p\(player.playerLabel)_attackright")!
                player.run(attackAction)
                x = 1; y = 0
                break
            case .up:
                attackAction = SKAction(named: "p\(player.playerLabel)_attackup")!
                player.run(attackAction)
                x = 0; y = 1
                break
            }
            let wait:SKAction = SKAction.wait(forDuration: 1)
            let finish:SKAction = SKAction.run {
                for i in 1...5{
                    let emitter = SKEmitterNode(fileNamed: "FireOnGrass")!
                    let position = CGPoint(x: node.position.x + CGFloat(80 * i) * x, y: node.position.y - 90 + CGFloat(80 * i) * y)
                    emitter.position = position
                    let swordRain = SKSpriteNode(texture: nil, color: UIColor.clear, size: CGSize(width: 80, height: 80))
                    swordRain.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 80, height: 80))
                    swordRain.physicsBody?.categoryBitMask = BodyType.grassOnFire.rawValue
                    swordRain.physicsBody?.collisionBitMask = 0
                    swordRain.position = position
                    self.addChild(swordRain)
                    if let grass = self.childNode(withName: "GrassTiles"){
                        grass.addChild(emitter)
                    }
                    let wait:SKAction = SKAction.wait(forDuration: 5)
                    let finish:SKAction = SKAction.run {
                        emitter.removeFromParent()
                        swordRain.removeFromParent()
                    }
                    let seq:SKAction = SKAction.sequence( [wait, finish] )
                    self.run(seq)
                }
            }
            let seq:SKAction = SKAction.sequence( [wait, finish] )
            run(seq)
        }
    }
    
    func addSwordRainOnGrassEmitter(node:SKNode){
        if let player = node as? Player{
            var attackAction = SKAction()
            var x:CGFloat = 0, y:CGFloat = 0
            switch player.face{
            case .down:
                attackAction = SKAction(named: "p\(player.playerLabel)_attackdown")!
                player.run(attackAction)
                x = 0; y = -1
                break
            case .left:
                attackAction = SKAction(named: "p\(player.playerLabel)_attackleft")!
                player.run(attackAction)
                x = -1;y = 0
                break
            case .right:
                attackAction = SKAction(named: "p\(player.playerLabel)_attackright")!
                player.run(attackAction)
                x = 1; y = 0
                break
            case .up:
                attackAction = SKAction(named: "p\(player.playerLabel)_attackup")!
                player.run(attackAction)
                x = 0; y = 1
                break
            }
            let wait:SKAction = SKAction.wait(forDuration: 1)
            let finish:SKAction = SKAction.run {
                for i in 1...3{
                    for j in -1...1{
                        let emitter = SKEmitterNode(fileNamed: "SwordRain")!
                        let positionX = node.position.x + CGFloat(80 * i) * x + 80 * (y * CGFloat(j))
                        let positionY = node.position.y - 90 + CGFloat(80 * i) * y + 80 * (x * CGFloat(j))
                        let effectPosition = CGPoint(x: positionX, y: positionY + 80 + y * 80)
                        let contactPosition = CGPoint(x: positionX, y: positionY)
                        emitter.position = effectPosition
                        let swordRain = SKSpriteNode(texture: nil, color: UIColor.clear, size: CGSize(width: 80, height: 80))
                        swordRain.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 80, height: 80))
                        swordRain.physicsBody?.categoryBitMask = BodyType.swordRain.rawValue
                        swordRain.physicsBody?.collisionBitMask = 0
                        swordRain.position = contactPosition
                        self.addChild(swordRain)
                        if let grass = self.childNode(withName: "GrassTiles"){
                            grass.addChild(emitter)
                        }
                        let wait:SKAction = SKAction.wait(forDuration: 2)
                        let finish:SKAction = SKAction.run {
                            emitter.removeFromParent()
                            swordRain.removeFromParent()
                        }
                        let seq:SKAction = SKAction.sequence( [wait, finish] )
                        self.run(seq)
                    }
                }
            }
            let seq:SKAction = SKAction.sequence( [wait, finish] )
            run(seq)
        }
    }
    
    func addSnowOnGrassEmitter(node:SKNode){
        if let player = node as? Player{
            var attackAction = SKAction()
            var x:CGFloat = 0, y:CGFloat = 0
            switch player.face{
            case .down:
                attackAction = SKAction(named: "p\(player.playerLabel)_attackdown")!
                player.run(attackAction)
                x = 0; y = -1
                break
            case .left:
                attackAction = SKAction(named: "p\(player.playerLabel)_attackleft")!
                player.run(attackAction)
                x = -1;y = 0
                break
            case .right:
                attackAction = SKAction(named: "p\(player.playerLabel)_attackright")!
                player.run(attackAction)
                x = 1; y = 0
                break
            case .up:
                attackAction = SKAction(named: "p\(player.playerLabel)_attackup")!
                player.run(attackAction)
                x = 0; y = 1
                break
            }
            let wait:SKAction = SKAction.wait(forDuration: 1)
            let finish:SKAction = SKAction.run {
                for i in 1...3{
                    for j in -2...2{
                        let emitter = SKEmitterNode(fileNamed: "SnowFlake")!
                        let positionX = node.position.x + CGFloat(80 * i) * x + 80 * (y * CGFloat(j))
                        let positionY = node.position.y - 90 + CGFloat(80 * i) * y + 80 * (x * CGFloat(j))
                        let position = CGPoint(x: positionX, y: positionY)
                        emitter.position = position
                        let snowFlake = SKSpriteNode(texture: nil, color: UIColor.clear, size: CGSize(width: 80, height: 80))
                        snowFlake.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 80, height: 80))
                        snowFlake.physicsBody?.categoryBitMask = BodyType.snowFlake.rawValue
                        snowFlake.physicsBody?.collisionBitMask = 0
                        snowFlake.position = position
                        self.addChild(snowFlake)
                        if let grass = self.childNode(withName: "GrassTiles"){
                            grass.addChild(emitter)
                        }
                        let wait:SKAction = SKAction.wait(forDuration: 5)
                        let finish:SKAction = SKAction.run {
                            emitter.removeFromParent()
                            snowFlake.removeFromParent()
                        }
                        let seq:SKAction = SKAction.sequence( [wait, finish] )
                        self.run(seq)
                    }
                }
            }
            let seq:SKAction = SKAction.sequence( [wait, finish] )
            run(seq)
        }
    }
    
}

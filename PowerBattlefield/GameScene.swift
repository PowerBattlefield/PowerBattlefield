//
//  GameScene.swift
//  PlayAround
//
//  Created by Justin Dike on 1/10/17.
//  Copyright © 2017 Justin Dike. All rights reserved.
//

import SpriteKit
import GameplayKit
import Firebase

enum BodyType:UInt32{
    
    case player = 1
    case building = 2
    case castle = 4
    case road = 8
    case water = 16
    case rock = 32
    case grass = 64
    
    //powers of 2 (so keep multiplying by 2
    
}


class GameScene: SKScene, SKPhysicsContactDelegate {
    var viewController: UIViewController?
    let screenWidth = UIScreen.main.bounds.width
    let screenHeight = UIScreen.main.bounds.height
    var thePlayer:SKSpriteNode = SKSpriteNode()
    var otherPlayer1:SKSpriteNode = SKSpriteNode()
    var theWeapon:SKSpriteNode = SKSpriteNode()
    var moveSpeed:TimeInterval = 1
    let swipeRightRec = UISwipeGestureRecognizer()
    let swipeLeftRec = UISwipeGestureRecognizer()
    let swipeUpRec = UISwipeGestureRecognizer()
    let swipeDownRec = UISwipeGestureRecognizer()
    let rotateRec = UIRotationGestureRecognizer()
    let tapRec = UITapGestureRecognizer()
    var currentPlayer = 1
    
    //get room id from room view
    var roomId: String!
    
    
    //tile map
    var waterTileMap:SKTileMapNode = SKTileMapNode()
    var rockTileMap:SKTileMapNode = SKTileMapNode()
    var grassTileMap:SKTileMapNode = SKTileMapNode()
    
    let uid = Auth.auth().currentUser!.uid
    
    // game control button
    var Up_btn:SKSpriteNode = SKSpriteNode()
    var Down_btn:SKSpriteNode = SKSpriteNode()
    var Left_btn:SKSpriteNode = SKSpriteNode()
    var Right_btn:SKSpriteNode = SKSpriteNode()
    var Attack_btn:SKSpriteNode = SKSpriteNode()
    var Quit_btn:SKSpriteNode = SKSpriteNode()

    
    //get player connections and set current player
//    func getPlayerConnectionNumber(){
//        playerConnections.observeSingleEvent(of: .value, with: { (snapshot) in
//
//            let playerConnectionNumber = snapshot.value as? Int ?? 0
//
//            self.numberOfPlayers = playerConnectionNumber
//
//            self.numberOfPlayers = self.numberOfPlayers + 1;
//
//            self.currentPlayer = self.numberOfPlayers
//
//            self.playerConnections.setValue(self.numberOfPlayers)
//
//            self.setPlayers()
//        }) { (error) in
//            print(error.localizedDescription)
//        }
//    }
    
    var p1Refx: DatabaseReference = Database.database().reference()
    var p1Refy: DatabaseReference = Database.database().reference()
    var p1RefMoveRight: DatabaseReference = Database.database().reference()
    var p1RefMoveLeft: DatabaseReference = Database.database().reference()
    var p1RefMoveUp: DatabaseReference = Database.database().reference()
    var p1RefMoveDown: DatabaseReference = Database.database().reference()
    var p2Refx: DatabaseReference = Database.database().reference()
    var p2Refy: DatabaseReference = Database.database().reference()
    var p2RefMoveRight: DatabaseReference = Database.database().reference()
    var p2RefMoveLeft: DatabaseReference = Database.database().reference()
    var p2RefMoveUp: DatabaseReference = Database.database().reference()
    var p2RefMoveDown: DatabaseReference = Database.database().reference()
    
    func setDatabaseReference(){
        p1Refx = Database.database().reference().child(roomId).child("player1").child("position").child("x")
        p1RefMoveRight = Database.database().reference().child(roomId).child("player1").child("move").child("right")
        p1RefMoveLeft = Database.database().reference().child(roomId).child("player1").child("move").child("left")
        p1RefMoveUp = Database.database().reference().child(roomId).child("player1").child("move").child("up")
        p1RefMoveDown = Database.database().reference().child(roomId).child("player1").child("move").child("down")
        p2RefMoveRight = Database.database().reference().child(roomId).child("player2").child("move").child("right")
        p2RefMoveLeft = Database.database().reference().child(roomId).child("player2").child("move").child("left")
        p2RefMoveUp = Database.database().reference().child(roomId).child("player2").child("move").child("up")
        p2RefMoveDown = Database.database().reference().child(roomId).child("player2").child("move").child("down")
        p1Refy = Database.database().reference().child(roomId).child("player1").child("position").child("y")
        p2Refx = Database.database().reference().child(roomId).child("player2").child("position").child("x")
        p2Refy = Database.database().reference().child(roomId).child("player2").child("position").child("y")
    }
    
    func setPlayers(){
        if(currentPlayer == 1){
            if let somePlayer:SKSpriteNode = self.childNode(withName: "Player1") as? SKSpriteNode {
                thePlayer = somePlayer
                thePlayer.physicsBody?.categoryBitMask = BodyType.player.rawValue
                thePlayer.physicsBody?.collisionBitMask = BodyType.castle.rawValue | BodyType.road.rawValue | BodyType.water.rawValue
                thePlayer.physicsBody?.contactTestBitMask = BodyType.building.rawValue | BodyType.castle.rawValue | BodyType.player.rawValue | BodyType.water.rawValue
                theWeapon = (thePlayer.childNode(withName: "Sword") as? SKSpriteNode)!
                
            }
            if let somePlayer:SKSpriteNode = self.childNode(withName: "Player2") as? SKSpriteNode {
                otherPlayer1 = somePlayer
                otherPlayer1.physicsBody?.categoryBitMask = BodyType.player.rawValue
                otherPlayer1.physicsBody?.collisionBitMask = BodyType.castle.rawValue | BodyType.road.rawValue | BodyType.water.rawValue
                otherPlayer1.physicsBody?.contactTestBitMask = BodyType.building.rawValue | BodyType.castle.rawValue | BodyType.player.rawValue | BodyType.water.rawValue
                //theWeapon = (thePlayer.childNode(withName: "Sword") as? SKSpriteNode)!
                
            }
        }else{
            if let somePlayer:SKSpriteNode = self.childNode(withName: "Player2") as? SKSpriteNode {
                thePlayer = somePlayer
                thePlayer.physicsBody?.categoryBitMask = BodyType.player.rawValue
                thePlayer.physicsBody?.collisionBitMask = BodyType.castle.rawValue | BodyType.road.rawValue | BodyType.water.rawValue
                thePlayer.physicsBody?.contactTestBitMask = BodyType.building.rawValue | BodyType.castle.rawValue | BodyType.player.rawValue | BodyType.water.rawValue
                //theWeapon = (thePlayer.childNode(withName: "Sword") as? SKSpriteNode)!
                
            }
            if let somePlayer:SKSpriteNode = self.childNode(withName: "Player1") as? SKSpriteNode {
                otherPlayer1 = somePlayer
                otherPlayer1.physicsBody?.categoryBitMask = BodyType.player.rawValue
                otherPlayer1.physicsBody?.collisionBitMask = BodyType.castle.rawValue | BodyType.road.rawValue | BodyType.water.rawValue
                otherPlayer1.physicsBody?.contactTestBitMask = BodyType.building.rawValue | BodyType.castle.rawValue | BodyType.player.rawValue | BodyType.water.rawValue
                theWeapon = (otherPlayer1.childNode(withName: "Sword") as? SKSpriteNode)!
                
            }
            
        }
    }
    
    override func willMove(from view: SKView) {
        self.removeAllActions()
        self.removeAllChildren()
    }
    
    override func didMove(to view: SKView) {
        if let id = self.userData?.value(forKey: "roomId") {
            roomId = id as! String
            print("roomId is :\(roomId)")
        }
        if let number = self.userData?.value(forKey: "playerNumber"){
            currentPlayer = number as! Int
        }
        setDatabaseReference()
        setPlayers()
        Database.database().reference().child(roomId).child("gameIsOn").observe(DataEventType.value){ (snapshot) in
            let gameIsOn = snapshot.value as! Bool
            if !gameIsOn{
                if let s = self.view?.scene{
                    NotificationCenter.default.removeObserver(self)
                    self.children
                        .forEach {
                            $0.removeAllActions()
                            $0.removeAllChildren()
                            $0.removeFromParent()
                    }
                    s.removeAllActions()
                    s.removeAllChildren()
                    s.removeFromParent()
                }
                self.cleanUp()
                Database.database().reference().child(self.roomId).child("gameIsOn").removeAllObservers()
                self.viewController?.dismiss(animated: true, completion: nil)
                //self.viewController?.performSegue(withIdentifier: "quit", sender: self.viewController)
            }
        }
        self.physicsWorld.contactDelegate = self

        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        
        tapRec.addTarget(self, action:#selector(GameScene.tappedView))
        tapRec.numberOfTouchesRequired = 1
        tapRec.numberOfTapsRequired = 2
        self.view!.addGestureRecognizer(tapRec)

        /*
         rotateRec.addTarget(self, action: #selector (GameScene.rotatedView (_:) ))
         self.view!.addGestureRecognizer(rotateRec)

         */

        swipeRightRec.addTarget(self, action: #selector(GameScene.swipedRight) )
        swipeRightRec.direction = .right
        self.view!.addGestureRecognizer(swipeRightRec)

        swipeLeftRec.addTarget(self, action: #selector(GameScene.swipedLeft) )
        swipeLeftRec.direction = .left
        self.view!.addGestureRecognizer(swipeLeftRec)


        swipeUpRec.addTarget(self, action: #selector(GameScene.swipedUp) )
        swipeUpRec.direction = .up
        self.view!.addGestureRecognizer(swipeUpRec)

        swipeDownRec.addTarget(self, action: #selector(GameScene.swipedDown) )
        swipeDownRec.direction = .down
        self.view!.addGestureRecognizer(swipeDownRec)

        // setup camera size

        let cameraSize = CGSize(width: CGFloat(screenWidth * 2), height: CGFloat(screenHeight * 2))
        scene?.size = cameraSize

        updateCamera()

        for node in self.children {

            if (node.name == "Building") {
                if (node is SKSpriteNode) {
                    node.physicsBody?.categoryBitMask = BodyType.building.rawValue
                    node.physicsBody?.collisionBitMask = 0
                    print ("found a building")
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
            // 改位置 加点击
            if (node.name == "Up_btn") {
                Up_btn = node as! SKSpriteNode
            }
            if (node.name == "Down_btn") {
                Down_btn = node as! SKSpriteNode
            }
            if (node.name == "Left_btn") {
                Left_btn = node as! SKSpriteNode
            }
            if (node.name == "Right_btn") {
               Right_btn = node as! SKSpriteNode
            }
            if (node.name == "Attack_btn") {
                Attack_btn = node as! SKSpriteNode
            }
            if (node.name == "Quit_btn") {
                Quit_btn = node as! SKSpriteNode
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
        updateControll(player_x: player_x, player_y: player_y, halfWidth: halfWidth, halfHeight: halfHeight)
    }
    func updateControll(player_x:CGFloat,player_y:CGFloat,halfWidth:CGFloat,halfHeight:CGFloat) {
        // attack and direction size are 200*200
        // each arror = 100*50 (x,y)
        //screenHeight 375.0 screenWidth 667.0
        var attack_x = player_x + screenWidth - 100
        var attack_y = player_y - screenHeight + 100
        var direction_x = player_x - screenWidth + 100 + 5
        var direction_y = player_y - screenHeight + 100 + 5
        var quit_x = player_x + screenWidth - 50
        var quit_y = player_y + screenHeight - 50
        
        let x_offset = attack_x - direction_x
        let y_offset = attack_y - direction_y
        let quit_y_offset = quit_y - attack_y
        // if out of bound
        if(player_x+screenWidth >= halfWidth) {
            attack_x = halfWidth - 100
            quit_x = halfWidth - 50
            direction_x = attack_x - x_offset
        }
        if(player_x-screenWidth <= -halfWidth) {
            direction_x = -halfWidth + 100 + 5
            attack_x = direction_x + x_offset
            quit_x = direction_x + x_offset + 50
        }
        if(player_y+screenHeight >= halfHeight) {
            attack_y = halfHeight - 2*screenHeight + 100
            quit_y = attack_y + quit_y_offset
            direction_y = attack_y - y_offset
        }
        if(player_y-screenHeight <= -halfHeight) {
            direction_y = -halfHeight + 100 + 5
            attack_y = direction_y + y_offset
            quit_y = attack_y + quit_y_offset
        }
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
                                tileNode.physicsBody?.collisionBitMask = BodyType.player.rawValue
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
    
    func observeOtherPlayerMovements(){
        p1RefMoveUp.observe(DataEventType.value) { (snapshot) in
            if self.currentPlayer != 1{
                self.move(theXAmount: 0, theYAmount: 100, theAnimation: "p1_walkup", player: self.otherPlayer1)
            }
        }
        p1RefMoveDown.observe(DataEventType.value) { (snapshot) in
            if self.currentPlayer != 1{
                self.move(theXAmount: 0, theYAmount: -100, theAnimation: "p1_walkdown", player: self.otherPlayer1)
            }
        }
        p1RefMoveLeft.observe(DataEventType.value) { (snapshot) in
            if self.currentPlayer != 1{
                self.move(theXAmount: -100, theYAmount: 0, theAnimation: "p1_walkleft", player: self.otherPlayer1)
            }
        }
        p1RefMoveRight.observe(DataEventType.value) { (snapshot) in
            if self.currentPlayer != 1{
                self.move(theXAmount: 100, theYAmount: 0, theAnimation: "p1_walkright", player: self.otherPlayer1)
            }
        }
        
        p2RefMoveUp.observe(DataEventType.value) { (snapshot) in
            if self.currentPlayer != 2{
                self.move(theXAmount: 0, theYAmount: 100, theAnimation: "p2_walkup", player: self.otherPlayer1)
            }
        }
        p2RefMoveDown.observe(DataEventType.value) { (snapshot) in
            if self.currentPlayer != 2{
                self.move(theXAmount: 0, theYAmount: -100, theAnimation: "p2_walkdown", player: self.otherPlayer1)
            }
        }
        p2RefMoveLeft.observe(DataEventType.value) { (snapshot) in
            if self.currentPlayer != 2{
                self.move(theXAmount: -100, theYAmount: 0, theAnimation: "p2_walkleft", player: self.otherPlayer1)
            }
        }
        p2RefMoveRight.observe(DataEventType.value) { (snapshot) in
            if self.currentPlayer != 2{
                self.move(theXAmount: 100, theYAmount: 0, theAnimation: "p2_walkright", player: self.otherPlayer1)
            }
        }
    }
    
    
    //MARK: ============= Gesture Recognizers
    
    @objc func tappedView() {
        
        thePlayer.run(SKAction(named: "p\(currentPlayer)_attackdown")!)
        if(currentPlayer == 1){
            theWeapon.run(SKAction(named: "sword_attackdown")!)
        }
    }
    
    var moveAmount = 0
    @objc func swipedRight() {
        moveAmount += 1
        if currentPlayer == 1{
            
            p1RefMoveRight.setValue("\(moveAmount)")
        }else if currentPlayer == 2{
            
            p2RefMoveRight.setValue("\(moveAmount)")
        }
        
        move(theXAmount: 100, theYAmount: 0, theAnimation: "p\(currentPlayer)_walkright", player: thePlayer)
    }
    
    @objc func swipedLeft() {
        moveAmount += 1
        if currentPlayer == 1{
            
            p1RefMoveLeft.setValue("\(moveAmount)")
        }else if currentPlayer == 2{
            
            p2RefMoveLeft.setValue("\(moveAmount)")
        }
        
        move(theXAmount: -100, theYAmount: 0, theAnimation: "p\(currentPlayer)_walkleft", player: thePlayer)
    }
    
    @objc func swipedUp() {
        moveAmount += 1
        if currentPlayer == 1{
            
            p1RefMoveUp.setValue("\(moveAmount)")
        }else if currentPlayer == 2{
            
            p2RefMoveUp.setValue("\(moveAmount)")
        }
        
        move(theXAmount: 0, theYAmount: 100, theAnimation: "p\(currentPlayer)_walkup", player: thePlayer)
    }
    
    @objc func swipedDown() {
        moveAmount += 1
        if currentPlayer == 1{
            
            p1RefMoveDown.setValue("\(moveAmount)")
        }else if currentPlayer == 2{
            
            p2RefMoveDown.setValue("\(moveAmount)")
        }
        
        move(theXAmount: 0, theYAmount: -100, theAnimation: "p\(currentPlayer)_walkdown", player: thePlayer)
        
        
    }
    
    
    
    
    
    func cleanUp(){
        
        //only need to call when presenting a different scene class
        
        for gesture in (self.view?.gestureRecognizers)! {
            
            self.view?.removeGestureRecognizer(gesture)
        }
        
        
    }
    
    
    
    func rotatedView(_ sender:UIRotationGestureRecognizer) {
        
        if (sender.state == .began) {
            
            print("rotation began")
            
        }
        if (sender.state == .changed) {
            
            print("rotation changed")
            
            //print(sender.rotation)
            
            let rotateAmount = Measurement(value: Double(sender.rotation), unit: UnitAngle.radians).converted(to: .degrees).value
            print(rotateAmount)
            
            thePlayer.zRotation = -sender.rotation
            
        }
        if (sender.state == .ended) {
            
            print("rotation ended")
            
            
        }
        
        
    }
    
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        updateCamera()
        for node in self.children {
            
            if (node.name == "Building") {
                
                if (node.position.y > thePlayer.position.y){
                    
                    node.zPosition = -100
                    
                } else {
                    
                    node.zPosition = 100
                    
                }
                
                
            }
        }
        
        
        
    }
    
    
    func move(theXAmount:CGFloat , theYAmount:CGFloat, theAnimation:String, player: SKSpriteNode)  {
        
        
        let wait:SKAction = SKAction.wait(forDuration: 0.05)
        
        let walkAnimation:SKAction = SKAction(named: theAnimation, duration: moveSpeed )!
        
        let moveAction:SKAction = SKAction.moveBy(x: theXAmount, y: theYAmount, duration: moveSpeed )
        
        let group:SKAction = SKAction.group( [ walkAnimation, moveAction ] )
        
        let finish:SKAction = SKAction.run {
            
            //print ( "Finish")
            
            
        }
        
        
        let seq:SKAction = SKAction.sequence( [wait, group, finish] )
        
        
        player.run(seq)
        
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            
            self.touchDown(atPoint: t.location(in: self))
            
            let location = t.location(in: self)
            let node = self.atPoint(location)
            if (node.name == "Attack_btn") {
                tappedView()
            }
            if (node.name == "Up_btn") {
                swipedUp()
            }
            if (node.name == "Down_btn") {
                swipedDown()
            }
            if (node.name == "Left_btn") {
                swipedLeft()
            }
            if (node.name == "Right_btn") {
                swipedRight()
            }
            if (node.name == "Quit_btn"){
                Database.database().reference().child(roomId).child("gameIsOn").setValue(false)
            }
            break
            
        }
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    
    //MARK: Physics contacts 
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        if (contact.bodyA.categoryBitMask == BodyType.player.rawValue && contact.bodyB.categoryBitMask == BodyType.building.rawValue) {
            
            print ("touched a building")
        } else if (contact.bodyB.categoryBitMask == BodyType.player.rawValue && contact.bodyA.categoryBitMask == BodyType.building.rawValue) {
            
            print ("touched a building")
            
            
            
        } else if (contact.bodyA.categoryBitMask == BodyType.player.rawValue && contact.bodyB.categoryBitMask == BodyType.castle.rawValue) {
            
            print ("touched a castle")
        } else if (contact.bodyB.categoryBitMask == BodyType.player.rawValue && contact.bodyA.categoryBitMask == BodyType.castle.rawValue) {
            
            print ("touched a castle")
        }else if (contact.bodyB.categoryBitMask == BodyType.player.rawValue && contact.bodyA.categoryBitMask == BodyType.player.rawValue) {
            
            print ("touched a player")
        }
        
        
    }
    
    
    
    
}




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
    
    //powers of 2 (so keep multiplying by 2
    
}


class GameScene: SKScene, SKPhysicsContactDelegate {
    
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
    var tileMap = SKTileMapNode()
    let currentPlayer = 2
    
    let p1Refx = Database.database().reference().child("player1").child("position").child("x")
    let p1RefMoveRight = Database.database().reference().child("player1").child("move").child("right")
    let p1RefMoveLeft = Database.database().reference().child("player1").child("move").child("left")
    let p1RefMoveUp = Database.database().reference().child("player1").child("move").child("up")
    let p1RefMoveDown = Database.database().reference().child("player1").child("move").child("down")
    let p2RefMoveRight = Database.database().reference().child("player2").child("move").child("right")
    let p2RefMoveLeft = Database.database().reference().child("player2").child("move").child("left")
    let p2RefMoveUp = Database.database().reference().child("player2").child("move").child("up")
    let p2RefMoveDown = Database.database().reference().child("player2").child("move").child("down")
    let p1Refy = Database.database().reference().child("player1").child("position").child("y")
    let p2Refx = Database.database().reference().child("player2").child("position").child("x")
    let p2Refy = Database.database().reference().child("player2").child("position").child("y")
    
    
    override func didMove(to view: SKView) {
        
        self.physicsWorld.contactDelegate = self
        
        self.physicsWorld.gravity = CGVector(dx: 1, dy: 0)
        
        
        
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
        
        if(currentPlayer == 1){
            if let somePlayer:SKSpriteNode = self.childNode(withName: "Player1") as? SKSpriteNode {
                thePlayer = somePlayer
                thePlayer.physicsBody?.categoryBitMask = BodyType.player.rawValue
                thePlayer.physicsBody?.collisionBitMask = BodyType.castle.rawValue | BodyType.road.rawValue
                thePlayer.physicsBody?.contactTestBitMask = BodyType.building.rawValue | BodyType.castle.rawValue | BodyType.player.rawValue
                theWeapon = (thePlayer.childNode(withName: "Sword") as? SKSpriteNode)!
                
            }
            if let somePlayer:SKSpriteNode = self.childNode(withName: "Player2") as? SKSpriteNode {
                otherPlayer1 = somePlayer
                otherPlayer1.physicsBody?.categoryBitMask = BodyType.player.rawValue
                otherPlayer1.physicsBody?.collisionBitMask = BodyType.castle.rawValue | BodyType.road.rawValue
                otherPlayer1.physicsBody?.contactTestBitMask = BodyType.building.rawValue | BodyType.castle.rawValue | BodyType.player.rawValue
                //theWeapon = (thePlayer.childNode(withName: "Sword") as? SKSpriteNode)!
                
            }
        }else{
            if let somePlayer:SKSpriteNode = self.childNode(withName: "Player2") as? SKSpriteNode {
                thePlayer = somePlayer
                thePlayer.physicsBody?.categoryBitMask = BodyType.player.rawValue
                thePlayer.physicsBody?.collisionBitMask = BodyType.castle.rawValue | BodyType.road.rawValue
                thePlayer.physicsBody?.contactTestBitMask = BodyType.building.rawValue | BodyType.castle.rawValue | BodyType.player.rawValue
                //theWeapon = (thePlayer.childNode(withName: "Sword") as? SKSpriteNode)!
                
            }
            if let somePlayer:SKSpriteNode = self.childNode(withName: "Player1") as? SKSpriteNode {
                otherPlayer1 = somePlayer
                otherPlayer1.physicsBody?.categoryBitMask = BodyType.player.rawValue
                otherPlayer1.physicsBody?.collisionBitMask = BodyType.castle.rawValue | BodyType.road.rawValue
                otherPlayer1.physicsBody?.contactTestBitMask = BodyType.building.rawValue | BodyType.castle.rawValue | BodyType.player.rawValue
                theWeapon = (otherPlayer1.childNode(withName: "Sword") as? SKSpriteNode)!
                
            }
        }
        
        
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
            
        }
        
        self.tileMap = (self.childNode(withName: "Tile Map") as? SKTileMapNode)!
        
        let tileSize = tileMap.tileSize
        let halfWidth = CGFloat(tileMap.numberOfColumns) / 2.0 * tileSize.width
        let halfHeight = CGFloat(tileMap.numberOfRows) / 2.0 * tileSize.height
        
        for col in 0..<tileMap.numberOfColumns {
            for row in 0..<tileMap.numberOfRows {
                let tileDefinition = tileMap.tileDefinition(atColumn: col, row: row)
                let isEdgeTile = tileDefinition?.userData?["edgeTile"] as? Bool
                if (isEdgeTile ?? false) {
                    let x = CGFloat(col) * tileSize.width - halfWidth
                    let y = CGFloat(row) * tileSize.height - halfHeight
                    let rect = CGRect(x: 0, y: 0, width: tileSize.width, height: tileSize.height)
                    let tileNode = SKShapeNode(rect: rect)
                    tileNode.position = CGPoint(x: x, y: y)
                    tileNode.physicsBody = SKPhysicsBody.init(rectangleOf: tileSize, center: CGPoint(x: tileSize.width / 2.0, y: tileSize.height / 2.0))
                    tileNode.physicsBody?.isDynamic = false
                    tileNode.physicsBody?.collisionBitMask = BodyType.player.rawValue
                    tileNode.physicsBody?.categoryBitMask = BodyType.road.rawValue
                    tileMap.addChild(tileNode)
                }
            }
        }
        
        observeOtherPlayerMovements()
        
        
        
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




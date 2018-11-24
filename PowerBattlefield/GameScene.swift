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
    
    //get room id from room view
    var roomId: String!
    
    
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
    
    func setPlayers(){
        if(currentPlayer == 1){
            if let somePlayer = self.childNode(withName: "Player1") as? Player {
                thePlayer = somePlayer
                thePlayer.initialize(playerLabel: 1, roomId: roomId)
            }
            if let somePlayer = self.childNode(withName: "Player2") as? Player {
                otherPlayer1 = somePlayer
                otherPlayer1.initialize(playerLabel: 2, roomId: roomId)
            }
        }else{
            if let somePlayer = self.childNode(withName: "Player2") as? Player {
                thePlayer = somePlayer
                thePlayer.initialize(playerLabel: 2, roomId: roomId)
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
                self.viewController?.dismiss(animated: true, completion: nil)
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
        otherPlayer1.refMoveUp.observe(DataEventType.value) { (snapshot) in
            if snapshot.value != nil{
                self.otherPlayer1.moveUp(otherPlayer: true)
            }
        }
        otherPlayer1.refMoveDown.observe(DataEventType.value) { (snapshot) in
            if snapshot.value != nil{
                self.otherPlayer1.moveDown(otherPlayer: true)
            }
        }
        otherPlayer1.refMoveLeft.observe(DataEventType.value) { (snapshot) in
            if snapshot.value != nil{
                self.otherPlayer1.moveLeft(otherPlayer: true)
            }
        }
        otherPlayer1.refMoveRight.observe(DataEventType.value) { (snapshot) in
            if snapshot.value != nil{
                self.otherPlayer1.moveRight(otherPlayer: true)
            }
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
                thePlayer.attack()
            }
            if (node.name == "Up_btn") {
                thePlayer.moveUp(otherPlayer: false)
            }
            if (node.name == "Down_btn") {
                thePlayer.moveDown(otherPlayer: false)
            }
            if (node.name == "Left_btn") {
                thePlayer.moveLeft(otherPlayer: false)
            }
            if (node.name == "Right_btn") {
                thePlayer.moveRight(otherPlayer: false)
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

//
//  GameViewController.swift
//  PlayAround
//
//  Created by Justin Dike on 1/10/17.
//  Copyright © 2017 Justin Dike. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {
    var roomId :String!
    var playerNumber :Int!
    let screenWidth = UIScreen.main.bounds.width
    let screenHeight = UIScreen.main.bounds.height
    let appDeleagte = UIApplication.shared.delegate as! AppDelegate
    override func viewDidLoad() {
        appDeleagte.allowRotation = true
        super.viewDidLoad()
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            if let scene = SKScene(fileNamed: "GameScene") {
                // Set the scale mode to scale to fit the window
                //scene.size
                scene.size = CGSize(width: CGFloat(screenHeight), height: CGFloat(screenWidth))
                scene.scaleMode = .aspectFit
                
                scene.userData = NSMutableDictionary()
                scene.userData?.setValue(roomId, forKey: "roomId")
                scene.userData?.setValue(playerNumber, forKey: "playerNumber")
                // Present the scene
                view.presentScene(scene)
            }
            
            view.ignoresSiblingOrder = true
            view.showsPhysics = false
            view.showsFPS = true
            view.showsNodeCount = true
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("123")
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}

import UIKit
import SpriteKit
import GameplayKit
import Firebase
class GameViewController: UIViewController {
    var roomId :String!
    var roomName :String!
    var roomOwner :String!
    var playerNumber :Int!
    let screenWidth = UIScreen.main.bounds.width
    let screenHeight = UIScreen.main.bounds.height
    let appDeleagte = UIApplication.shared.delegate as! AppDelegate
    override func viewDidLoad() {
        appDeleagte.allowRotation = true
        super.viewDidLoad()
        var number = 1
        Database.database().reference().child(roomId).child("playerNames").observe(DataEventType.value){ (snapshot) in
            for rest in snapshot.children{
                let player = rest as! DataSnapshot
                if Auth.auth().currentUser?.uid == player.key{
                    self.playerNumber = number
                    break
                }
                number += 1
            }
            self.goToGameScene()
        }
        
    }
    
    func goToGameScene(){
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            if let scene = GameScene(fileNamed: "GameScene") {
                // Set the scale mode to scale to fit the window
                //scene.size
                scene.size = CGSize(width: CGFloat(screenHeight), height: CGFloat(screenWidth))
                scene.scaleMode = SKSceneScaleMode.resizeFill
                scene.viewController = self
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

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is RoomViewController{
            let newVC = segue.destination as! RoomViewController
            newVC.roomId = self.roomId
            newVC.roomName = self.roomName
            newVC.roomOwner = self.roomOwner
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

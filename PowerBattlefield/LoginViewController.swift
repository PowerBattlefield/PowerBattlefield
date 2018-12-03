import UIKit
import FirebaseUI
import AVFoundation

class LoginViewController: UIViewController {
    var uid = ""
    let appDeleagte = UIApplication.shared.delegate as! AppDelegate
    var audioPlayer: AVAudioPlayer!
    
    func playBgMusic() {
        let musicPath = Bundle.main.path(forResource: "login", ofType: "mp3")
        let url = NSURL(fileURLWithPath: musicPath!)
        if(audioPlayer == nil){
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: url as URL, fileTypeHint: "fail")
                audioPlayer.numberOfLoops = -1
                audioPlayer.volume = 0.5
                audioPlayer.prepareToPlay()
                audioPlayer.play()
            } catch {
                print("file read failed!")
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        playBgMusic()
        self.hideKeyboard()
        // Do any additional setup after loading the view.
        appDeleagte.allowRotation = true
        let background = UIImage(named: "bglogin")
        self.view.backgroundColor = UIColor(patternImage: background!)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "show" {
            if let destinationVC = segue.destination as? LobbyViewController  {
                destinationVC.audioPlayer = self.audioPlayer
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let value = UIInterfaceOrientation.landscapeLeft.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let id = Auth.auth().currentUser?.uid {
            uid = id
        }else{
            uid = ""
        }
        //if logged in user, go to lobby view
        if(uid.count > 0){
            performSegue(withIdentifier: "show", sender: self)
        }
    }

    @IBAction func loginBtn(_ sender: Any) {
        let authUI = FUIAuth.defaultAuthUI()
        
        guard authUI != nil else{
            print("log in error")
            
            return
        }
        
        authUI?.delegate = self
        
        let authViewConroller = authUI!.authViewController()
        authViewConroller.hideKeyboard()
        present(authViewConroller, animated: true, completion: nil)
        
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension LoginViewController: FUIAuthDelegate{
    func authUI(_ authUI: FUIAuth, didSignInWith authDataResult: AuthDataResult?, error: Error?) {
        
        if error != nil{
            print(error ?? "error")
            return
        }
        
        performSegue(withIdentifier: "show", sender: self)
    }
}

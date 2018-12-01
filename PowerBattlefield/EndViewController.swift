import UIKit
import Firebase
import AVFoundation

class EndViewController: UIViewController {
    
    var displayText = ""
    var roomId:String!
    var audioPlayer: AVAudioPlayer!
    let appDeleagte = UIApplication.shared.delegate as! AppDelegate
    @IBOutlet weak var displayLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        displayLabel.text = displayText
        // Do any additional setup after loading the view.
        let room = Database.database().reference().child(roomId)
        room.removeValue()
        room.child("kickPlayer").observe(DataEventType.value){ (snapshot) in
            let uid = snapshot.value as? String ?? ""
            if uid == Auth.auth().currentUser?.uid{
                let room = Database.database().reference().child(self.roomId)
                room.child("playerNumber").setValue(1)
                room.child("playerNames").child(Auth.auth().currentUser!.uid).removeValue()
                room.child("playerIsReady").child(Auth.auth().currentUser!.uid).removeValue()
                room.child("kickPlayer").removeValue()
                self.appDeleagte.isInRoom = false
                let newVC = self.storyboard?.instantiateViewController(withIdentifier: "LobbyVC") as! LobbyViewController
                newVC.audioPlayer = self.audioPlayer
                self.present(newVC, animated: true, completion: nil)
            }
        }
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "backtoroom")!)
        
    }
    


    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let newVC = segue.destination as? LobbyViewController{
            newVC.audioPlayer = self.audioPlayer
        }
    }


}

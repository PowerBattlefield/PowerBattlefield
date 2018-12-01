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
    }
    
    @IBAction func backToRoom(_ sender: Any) {
        Database.database().reference().child(roomId).child("winner").removeValue()
        Database.database().reference().child(roomId).child("player1").removeValue()
        Database.database().reference().child(roomId).child("player2").removeValue()
        dismiss(animated: true, completion: nil)
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

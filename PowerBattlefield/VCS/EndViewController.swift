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
        Database.database().reference().child(roomId).removeValue()

        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "backtoroom")!)
        
    }
    


    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let newVC = segue.destination as? LobbyViewController{
            newVC.audioPlayer = self.audioPlayer
        }
    }


}

import UIKit
import Firebase
import AVFoundation

class CreateRoomViewController: UIViewController {

    @IBOutlet weak var roompwd: UITextField!
    @IBOutlet weak var roomName: UITextField!
    @IBOutlet weak var create: UIButton!
    var roomId:Int!
    var audioPlayer: AVAudioPlayer!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboard()
        // Do any additional setup after loading the view.

        // Do any additional setup after loading the view.'
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "bgcreateroom")!)
        roomName.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.6)
        roompwd.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.6)
        create.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        create.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.6)
        create.layer.cornerRadius = 20
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancelCreate(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func create(_ sender: Any) {
        if(self.roomName.text!.count > 0){
            let roomNumber = Database.database().reference().child("number of rooms")
            roomNumber.observeSingleEvent(of: .value, with: { (snapshot) in
                self.roomId = snapshot.value as? Int ?? 0
                self.roomId = self.roomId + 1
                roomNumber.setValue(self.roomId)
                let room = Database.database().reference().child(String(self.roomId))
                room.child("roomName").setValue(self.roomName.text)
                room.child("roomOwner").setValue(Auth.auth().currentUser?.uid)
                let newVC = self.storyboard?.instantiateViewController(withIdentifier: "RoomVC") as! RoomViewController
                newVC.roomId = String(self.roomId)
                newVC.roomName = self.roomName.text
                newVC.roomOwner = Auth.auth().currentUser?.uid
                newVC.audioPlayer = self.audioPlayer
                self.present(newVC, animated: true, completion: nil)
            }) { (error) in
                print(error.localizedDescription)
            }
        }
    }

}

import UIKit
import Firebase
class CreateRoomViewController: UIViewController {

    @IBOutlet weak var roompwd: UITextField!
    @IBOutlet weak var roomName: UITextField!
    @IBOutlet weak var create: UIButton!
    var roomId:Int!
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
    
    @IBAction func create(_ sender: Any) {
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
            self.present(newVC, animated: true, completion: nil)
        }) { (error) in
            print(error.localizedDescription)
        }
    }

}

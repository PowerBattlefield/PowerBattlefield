import UIKit
import Firebase

class RoomViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return players.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "playerCell")
        let uid = players.keys[players.index(players.startIndex, offsetBy: indexPath.row)]
        let text = players[uid]
        cell.textLabel?.text = text
        if uid == roomOwner{
            cell.imageView?.image = #imageLiteral(resourceName: "room_owner")
        }else {
            if playerIsReady[uid] != nil && playerIsReady[uid]!{
                cell.imageView?.image = #imageLiteral(resourceName: "ready")
            }else{
                cell.imageView?.image = #imageLiteral(resourceName: "unready")
            }
        }
        if Auth.auth().currentUser?.uid == roomOwner && Auth.auth().currentUser?.uid != uid{
            let kick_btn = UIButton(frame: CGRect(x: cell.frame.midX + 30, y: 0, width: 50, height: cell.frame.height))
            kick_btn.setTitleColor(UIColor.blue, for: .normal)
            kick_btn.tag = indexPath.row
            kick_btn.setTitle("kick", for: .normal)
            kick_btn.addTarget(self, action: #selector(kick), for: .touchUpInside)
            cell.addSubview(kick_btn)
        }
        if Auth.auth().currentUser?.uid == uid{
            cell.backgroundColor = UIColor(white: 0.9, alpha: 1)
        }
        return cell
    }
    
    

    @IBOutlet weak var startOrReadyBtn: UIButton!
    @IBOutlet weak var chatDisplay: UITextView!
    @IBOutlet weak var textInput: UITextField!
    @IBOutlet weak var playerList: UITableView!
    @IBOutlet weak var roomNameLabel: UILabel!
    @IBOutlet weak var send: UIButton!
    var roomId :String!
    var roomName:String!
    var number: Int!
    var roomOwner:String!
    var players:[String:String] = [:]
    let appDeleagte = UIApplication.shared.delegate as! AppDelegate
    var playerIsReady:[String:Bool] = [:]

    func gameEnds(){
        Database.database().reference().child(roomId).child("winner").observe(DataEventType.value) { (snapshot) in
            if let winnerLabel = snapshot.value as? Int{
                Database.database().reference().child(self.roomId).child(Auth.auth().currentUser!.uid).observe(DataEventType.value){ (snapshot) in
                    if let playerLabel = snapshot.value as? Int{
                        self.appDeleagte.isInRoom = false
                        if winnerLabel == playerLabel{
                            let newVC = self.storyboard?.instantiateViewController(withIdentifier: "EndVC") as! EndViewController
                            newVC.roomId = self.roomId
                            newVC.displayText = "Congratulations! You win the game!"
                            self.present(newVC, animated: false, completion: nil)
                        }else{
                            let newVC = self.storyboard?.instantiateViewController(withIdentifier: "EndVC") as! EndViewController
                            newVC.roomId = self.roomId
                            newVC.displayText = "You lose!"
                            self.present(newVC, animated: false, completion: nil)
                        }
                    }
                }
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboard()
        let background = UIImage(named: "mountain")
        self.view.backgroundColor = UIColor(patternImage: background!)
        gameEnds()
        chatDisplay.isEditable = false
        playerList.delegate = self
        playerList.dataSource = self
        roomNameLabel.text = roomName
        chatDisplay.backgroundColor = UIColor.white
        textInput.backgroundColor = UIColor.white
        startOrReadyBtn.backgroundColor = UIColor.white
        send.backgroundColor = UIColor.white
        startOrReadyBtn.layer.masksToBounds = true
        //        textInput.layer.cornerRadius = 20
        //        textInput.layer.masksToBounds = true
        playerList.backgroundColor = UIColor.white
        playerList.alpha = 0.8
        chatDisplay.alpha = 0.8
        startOrReadyBtn.alpha = 0.8
        textInput.alpha = 0.8
        send.alpha = 0.8
        send.layer.masksToBounds = true
        self.view.bringSubview(toFront: roomNameLabel)
        let room = Database.database().reference().child(roomId)
        room.child("gameIsOn").setValue(false)
        if Auth.auth().currentUser?.uid == roomOwner{
            startOrReadyBtn.setTitle("Start", for: .normal)
            room.child("playerIsReady").child(Auth.auth().currentUser!.uid).setValue(true)
        }else{
            startOrReadyBtn.setTitle("Ready", for: .normal)
            room.child("playerIsReady").child(Auth.auth().currentUser!.uid).setValue(false)
        }
        let playerNumber = room.child("playerNumber")
//        playerNumber.observeSingleEvent(of: .value, with: { (snapshot) in
//            self.number = snapshot.value as? Int ?? 0
//            self.number = self.number + 1
//            playerNumber.setValue(self.number)
//        }) { (error) in
//            print(error.localizedDescription)
//        }
        let playerName = Auth.auth().currentUser?.displayName
        let playerID = Auth.auth().currentUser?.uid
        
        room.child("playerNames").child(playerID!).setValue(playerName)
        room.child("playerNames").observe(DataEventType.value){ (snapshot) in
            self.players = [:]
            for rest in snapshot.children{
                let player = rest as! DataSnapshot
                self.players[player.key] = player.value as? String
            }
            playerNumber.setValue(self.players.count)
            self.appDeleagte.players = self.players
            self.playerList.reloadData()
        }
        
        room.child("chatLog").observe(DataEventType.value){ (snapshot) in
            let text = snapshot.value as? String ?? ""
            if text != ""{
                let _ = text.prefix(upTo: text.index(of: ":")!)
                let _ = text.suffix(from: text.index(of: ":")!)
            }
            
            self.chatDisplay.text.append("\(text)\n")
            let range:NSRange = NSMakeRange((self.chatDisplay.text.lengthOfBytes(using: String.Encoding.utf8))-1, 1)
            self.chatDisplay.scrollRangeToVisible(range)
        }
        
        room.child("gameIsOn").observe(DataEventType.value){ (snapshot) in
            let gameIsOn = snapshot.value as? Bool ?? false
            if gameIsOn{
                let newVC = self.storyboard?.instantiateViewController(withIdentifier: "GameVC") as! GameViewController
                newVC.roomId = self.roomId
                newVC.roomName = self.roomName
                newVC.roomOwner = self.roomOwner
                self.present(newVC, animated: true, completion: nil)
            }
        }
        
        room.child("playerIsReady").observe(DataEventType.value){ (snapshot) in
            self.playerIsReady = [:]
            for rest in snapshot.children{
                let data = rest as! DataSnapshot
                self.playerIsReady[data.key] = data.value as? Bool
            }
            self.playerList.reloadData()
        }
        
        room.child("roomOwner").observe(DataEventType.value){ (snapshot) in
            self.roomOwner = snapshot.value as? String ?? ""
            if self.roomOwner == Auth.auth().currentUser?.uid{
                self.startOrReadyBtn.setTitle("Start", for: .normal)
            }
            self.playerList.reloadData()
        }
        
        room.child("kickPlayer").observe(DataEventType.value){ (snapshot) in
            let uid = snapshot.value as? String ?? ""
            if uid == Auth.auth().currentUser?.uid{
                let room = Database.database().reference().child(self.roomId)
                room.child("playerNumber").setValue(self.players.count-1)
                room.child("playerNames").child(Auth.auth().currentUser!.uid).removeValue()
                room.child("playerIsReady").child(Auth.auth().currentUser!.uid).removeValue()
                room.child("kickPlayer").removeValue()
                self.appDeleagte.isInRoom = false
                let newVC = self.storyboard?.instantiateViewController(withIdentifier: "LobbyVC") as! LobbyViewController
                self.present(newVC, animated: true, completion: nil)
            }
        }
        
        //appDeleagte.allowRotation = true
        appDeleagte.roomId = roomId
        appDeleagte.roomOwner = roomOwner
        appDeleagte.isInRoom = true
    }
        // Do any additional setup after loading the view.

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is GameViewController{
            let gameVC = segue.destination as! GameViewController
            gameVC.roomId = roomId
        }else {
        }
    }
    @IBAction func sendText(_ sender: Any) {
        if textInput.text != ""{
           let text = textInput.text!
            Database.database().reference().child(roomId).child("chatLog").setValue("\(Auth.auth().currentUser?.displayName ?? "Unknown"): \(text)")
            textInput.text = ""
        }
    }
    
    @IBAction func quitRoom(_ sender: Any) {
        let room = Database.database().reference().child(roomId)
        room.child("playerNames").removeAllObservers()
        room.child("playerNumber").setValue(players.count-1)
        room.child("playerNames").child(Auth.auth().currentUser!.uid).removeValue()
        room.child("playerIsReady").child(Auth.auth().currentUser!.uid).removeValue()
        players.remove(at: players.index(forKey: Auth.auth().currentUser!.uid)!)
        if Auth.auth().currentUser!.uid == roomOwner && players.count >= 1{
            let random = Int(arc4random_uniform(UInt32(players.count)))
            let uid = players.keys[players.index(players.startIndex, offsetBy: random)]
            room.child("roomOwner").setValue(uid)
        }else if Auth.auth().currentUser!.uid == roomOwner && players.count < 1{
            room.removeValue()
        }
        appDeleagte.isInRoom = false
        let newVC = self.storyboard?.instantiateViewController(withIdentifier: "LobbyVC") as! LobbyViewController
        self.present(newVC, animated: true, completion: nil)
    }
    
    
    @IBAction func startOrReady(_ sender: Any) {
        let room = Database.database().reference().child(roomId)
        if startOrReadyBtn.titleLabel?.text == "Start"{
            room.child("playerIsReady").observeSingleEvent(of: .value, with: { (snapshot) in
                var allIsReady = true
                for rest in snapshot.children{
                    let data = rest as! DataSnapshot
                    let isReady = data.value as! Bool
                    if !isReady{
                        allIsReady = false
                        break
                    }
                }
                if allIsReady{
                    room.child("gameIsOn").setValue(true)
                }
            })
        }else if startOrReadyBtn.titleLabel?.text == "Ready"{
            room.child("playerIsReady").child(Auth.auth().currentUser!.uid).setValue(true)
            startOrReadyBtn.setTitle("Unready", for: .normal)
        }else{
            startOrReadyBtn.setTitle("Ready", for: .normal)
            room.child("playerIsReady").child(Auth.auth().currentUser!.uid).setValue(false)
        }
    }
    
    func shouldAutorotate() -> Bool {
        return false
    }
    
    @objc func kick(sender: UIButton){
        let uid = players.keys[players.index(players.startIndex, offsetBy: sender.tag)]
        let room = Database.database().reference().child(roomId)
        room.child("kickPlayer").setValue(uid)
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

extension UIViewController
{
    func hideKeyboard()
    {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(UIViewController.dismissKeyboard))
        
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard()
    {
        view.endEditing(true)
    }
}

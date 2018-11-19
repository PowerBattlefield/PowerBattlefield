//
//  RoomViewController.swift
//  PowerBattlefield
//
//  Created by Da Lin on 11/17/18.
//  Copyright © 2018 Da Lin. All rights reserved.
//

import UIKit
import Firebase

class RoomViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return players.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "playerCell")
        let text = players[players.keys[players.index(players.startIndex, offsetBy: indexPath.row)]]
        cell.textLabel?.text = text
        return cell
    }
    
    

    @IBOutlet weak var chatDisplay: UITextView!
    @IBOutlet weak var textInput: UITextField!
    @IBOutlet weak var playerList: UITableView!
    @IBOutlet weak var roomNameLabel: UILabel!
    var roomId :String!
    var roomName:String!
    var number: Int!
    var players:[String:String] = [:]
    let appDeleagte = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        chatDisplay.isEditable = false
        playerList.delegate = self
        playerList.dataSource = self
        roomNameLabel.text = roomName
        self.view.bringSubview(toFront: roomNameLabel)
        let room = Database.database().reference().child(roomId)
        let playerNumber = room.child("playerNumber")
        playerNumber.observeSingleEvent(of: .value, with: { (snapshot) in
            self.number = snapshot.value as? Int ?? 0
            self.number = self.number + 1
            playerNumber.setValue(self.number)
        }) { (error) in
            print(error.localizedDescription)
        }
        let playerName = Auth.auth().currentUser?.displayName
        let playerID = Auth.auth().currentUser?.uid
        
        room.child("playerNames").child(playerID!).setValue(playerName)
        room.child("playerNames").observe(DataEventType.value){ (snapshot) in
            self.players = [:]
            for rest in snapshot.children{
                print(rest)
                let player = rest as! DataSnapshot
                self.players[player.key] = player.value as? String
            }
            self.playerList.reloadData()
        }
        
        room.child("chatLog").observe(DataEventType.value){ (snapshot) in
            let text = snapshot.value as? String ?? ""
            if text != ""{
                let name = text.prefix(upTo: text.index(of: ":")!)
                let chat = text.suffix(from: text.index(of: ":")!)
                print("\(name) \(chat)")
            }
            
            self.chatDisplay.text.append("\(text)\n")
            let range:NSRange = NSMakeRange((self.chatDisplay.text.lengthOfBytes(using: String.Encoding.utf8))-1, 1)
            self.chatDisplay.scrollRangeToVisible(range)
        }
        appDeleagte.allowRotation = true
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
    
    override func viewWillAppear(_ animated: Bool) {
        let value = UIInterfaceOrientation.landscapeLeft.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        appDeleagte.allowRotation = false
        let value = UIInterfaceOrientation.portrait.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
    }
    @IBAction func quitRoom(_ sender: Any) {
       Database.database().reference().child(roomId).child("playerNumber").setValue(players.count-1)
        Database.database().reference().child(roomId).child("playerNames").child((Auth.auth().currentUser?.uid)!).removeValue()
        
        let newVC = self.storyboard?.instantiateViewController(withIdentifier: "LobbyVC") as! LobbyViewController
        self.present(newVC, animated: true, completion: nil)
    }
    
    func shouldAutorotate() -> Bool {
        return false
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

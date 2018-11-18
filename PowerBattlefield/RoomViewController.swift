//
//  RoomViewController.swift
//  PowerBattlefield
//
//  Created by Da Lin on 11/17/18.
//  Copyright © 2018 Da Lin. All rights reserved.
//

import UIKit
import Firebase

class RoomViewController: UIViewController {
    
    //get room id from lobby view
    var roomId :String!
    var roomName:String!
    override func viewDidLoad() {
        super.viewDidLoad()
        var number: Int!
        let room = Database.database().reference().child(roomId)
        let playerNumber = room.child("playerNumber")
        room.child("roomName").setValue(roomName)
        playerNumber.observeSingleEvent(of: .value, with: { (snapshot) in
            
            number = snapshot.value as? Int ?? 0
            number = number + 1
            playerNumber.setValue(number)
        }) { (error) in
            print(error.localizedDescription)
        }
        let playerName = Auth.auth().currentUser?.displayName
        let playerID = Auth.auth().currentUser?.uid
        
        room.child("playerNames").child(playerID!).setValue(playerName)
        // Do any additional setup after loading the view.
    }
    
    @IBAction func resetBtnTyped(_ sender: Any) {
        
        let playerConnections = Database.database().reference().child(roomId!).child("playerConnections")
        playerConnections.setValue(0)
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is GameViewController{
            let gameVC = segue.destination as! GameViewController
            gameVC.roomId = roomId
        }else {
        }
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

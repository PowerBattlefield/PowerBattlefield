//
//  CreateRoomViewController.swift
//  PowerBattlefield
//
//  Created by labuser on 11/17/18.
//  Copyright © 2018 Da Lin. All rights reserved.
//

import UIKit
import Firebase
class CreateRoomViewController: UIViewController {

    @IBOutlet weak var roompwd: UITextField!
    @IBOutlet weak var roomName: UITextField!
    var roomId:Int!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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

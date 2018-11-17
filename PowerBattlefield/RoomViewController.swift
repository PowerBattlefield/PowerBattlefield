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
    let roomId = "1"

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func resetBtnTyped(_ sender: Any) {
        
        let playerConnections = Database.database().reference().child(roomId).child("playerConnections")
        playerConnections.setValue(0)
        
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

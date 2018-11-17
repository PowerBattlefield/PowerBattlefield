//
//  LobbyViewController.swift
//  PowerBattlefield
//
//  Created by Da Lin on 11/16/18.
//  Copyright © 2018 Da Lin. All rights reserved.
//

import UIKit
import FirebaseUI

class LobbyViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    

    @IBAction func signoutBtnTypped(_ sender: Any) {
        
        try! Auth.auth().signOut()
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

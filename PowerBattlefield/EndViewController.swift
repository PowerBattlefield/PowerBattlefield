//
//  EndViewController.swift
//  PowerBattlefield
//
//  Created by Da Lin on 11/24/18.
//  Copyright © 2018 Da Lin. All rights reserved.
//

import UIKit

class EndViewController: UIViewController {
    
    var displayText = ""

    @IBOutlet weak var displayLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        displayLabel.text = displayText
        // Do any additional setup after loading the view.
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

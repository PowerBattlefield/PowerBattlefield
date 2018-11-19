//
//  LobbyViewController.swift
//  PowerBattlefield
//
//  Created by Da Lin on 11/16/18.
//  Copyright © 2018 Da Lin. All rights reserved.
//

import UIKit
import FirebaseUI
import Firebase


class LobbyViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    var roomNumber:Int!
    var rooms:[Room]? = []
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(rooms != nil){
            return rooms!.count
        }else{
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "reuseCell")
        let text = rooms![indexPath.row].roomName
        cell.textLabel!.text = text
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let newVC = self.storyboard?.instantiateViewController(withIdentifier: "RoomVC") as! RoomViewController
        newVC.roomId = rooms![indexPath.row].roomId
        newVC.roomName = rooms![indexPath.row].roomName
        self.present(newVC, animated: true, completion: nil)
    }

    @IBOutlet weak var roomList: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        roomList.dataSource = self
        roomList.delegate = self
    }


    @IBAction func signoutBtnTypped(_ sender: Any) {
        try! Auth.auth().signOut()
        let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC") as! LoginViewController
        present(loginVC, animated: true, completion: nil)
    }
    override func viewDidAppear(_ animated: Bool) {
        let database = Database.database().reference()
        database.observe(DataEventType.value){ (snapshot) in
            self.rooms = []
            for rest in snapshot.children.allObjects as! [DataSnapshot]{
                if rest.key == "number of rooms"{
                    self.roomNumber = rest.value! as! Int
                }else{
                    let roomId = rest.key
                    var dict : [String:Any] = [:]
                    for child in rest.children{
                        let room = child as! DataSnapshot
                        dict[room.key] = room.value
                    }
                    if dict["playerNumber"] != nil && dict["roomName"] != nil{
                        let data = Room(playerNumber: dict["playerNumber"] as! Int, roomName: dict["roomName"] as! String, roomId: roomId)
                        self.rooms!.append(data)
                    }
                }
            }
            self.roomList.reloadData()
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        Database.database().reference().removeAllObservers()
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

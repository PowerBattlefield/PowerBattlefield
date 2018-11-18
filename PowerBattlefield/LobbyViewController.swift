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
            print(rooms?.count)
            return (rooms?.count)!
        }else{
            print("shabi")
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "reuseCell")
        print("cell")
        let text = rooms![indexPath.row].roomName
        cell.textLabel!.text = text
        return cell
    }
    

    @IBOutlet weak var roomList: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        roomList.dataSource = self
        roomList.delegate = self
    }

    @IBAction func signoutBtnTypped(_ sender: Any) {
        
        try! Auth.auth().signOut()
    }
    
    @IBAction func createRoom(_ sender: Any) {
        
    }
    override func viewDidAppear(_ animated: Bool) {
        let database = Database.database().reference()
        database.observe(DataEventType.value){ (snapshot) in
            for rest in snapshot.children.allObjects as! [DataSnapshot]{
                if rest.key == "number of rooms"{
                    self.roomNumber = rest.value! as! Int
                }else{
                    var dict : [String:Any] = [:]
                    for child in rest.children{
                        let room = child as! DataSnapshot
                        dict[room.key] = room.value
                    }
                    let data = Room(one: ["feifan"] , two: dict["playerNumber"] as! Int, thr: dict["roomName"] as! String)
                    print(data)
                    self.rooms!.append(data)
                    print(self.rooms!)
                }
            }
            //            print(self.rooms!)
            self.roomList.reloadData()
            //print(room)
        }
    }
    override func viewDidDisappear(_ animated: Bool) {
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

//
//  AppDelegate.swift
//  PowerBattlefield
//
//  Created by Da Lin on 11/4/18.
//  Copyright © 2018 Da Lin. All rights reserved.
//

import UIKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    var allowRotation = false
    var roomId:String?
    var count:Int?
    var isInRoom:Bool = false
    var players:[String:String] = [:]
    var roomOwner:String?
    
    override init(){
        FirebaseApp.configure()
    }

//    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
//        // Override point for customization after application launch.
//        return true
//    }

    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        if self.allowRotation {
            return UIInterfaceOrientationMask.landscape
        }
        return UIInterfaceOrientationMask.portrait
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        if isInRoom{
            let room = Database.database().reference().child(roomId!)
            room.child("playerNames").removeAllObservers()
            room.child("playerNumber").setValue(players.count-1)
            room.child("playerNames").child(Auth.auth().currentUser!.uid).removeValue()
            room.child("playerIsReady").child(Auth.auth().currentUser!.uid).removeValue()
            players.remove(at: players.index(forKey: Auth.auth().currentUser!.uid)!)
            if Auth.auth().currentUser!.uid == roomOwner! && players.count >= 1{
                let random = Int(arc4random_uniform(UInt32(players.count)))
                let uid = players.keys[players.index(players.startIndex, offsetBy: random)]
                room.child("roomOwner").setValue(uid)
            }else if Auth.auth().currentUser!.uid == roomOwner! && players.count < 1{
                room.removeValue()
            }
        }
    }


}


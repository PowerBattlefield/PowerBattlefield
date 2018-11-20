//
//  roomAPI.swift
//  PowerBattlefield
//
//  Created by labuser on 11/18/18.
//  Copyright © 2018 Da Lin. All rights reserved.
//

import Foundation

struct Room{
    var roomId:String!
    var playerNumber:Int!
    var roomName:String!
    var roomOwner:String!
    init(playerNumber:Int,roomName:String,roomId:String,roomOwner:String){
        self.playerNumber = playerNumber
        self.roomName = roomName
        self.roomId = roomId
        self.roomOwner = roomOwner
    }
}


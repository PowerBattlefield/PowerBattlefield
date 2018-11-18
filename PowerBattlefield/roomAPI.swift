//
//  roomAPI.swift
//  PowerBattlefield
//
//  Created by labuser on 11/18/18.
//  Copyright © 2018 Da Lin. All rights reserved.
//

import Foundation

struct Room{
    var playerNames:[String]!
    var playerNumber:Int!
    var roomName:String!
    init(one:[String],two:Int,thr:String){
        playerNames = one
        playerNumber = two
        roomName = thr
    }
}


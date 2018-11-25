import Foundation

struct Room{
    var roomId:String!
    var playerNumber:Int!
    var roomName:String!
    var roomOwner:String!
    var gameIsOn:Bool!
    init(playerNumber:Int,roomName:String,roomId:String,roomOwner:String,gameIsOn:Bool){
        self.playerNumber = playerNumber
        self.roomName = roomName
        self.roomId = roomId
        self.roomOwner = roomOwner
        self.gameIsOn = gameIsOn
    }
}


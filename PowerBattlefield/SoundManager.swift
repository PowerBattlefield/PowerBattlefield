//
//  SoundManager.swift
//  PowerBattlefield
//
//  Created by 郭阳 on 12/1/18.
//  Copyright © 2018 Da Lin. All rights reserved.
//

import Foundation
import SpriteKit
//引入多媒体框架
import AVFoundation

class SoundManager :SKNode{
    //申明一个播放器
    var BGMPlayer = AVAudioPlayer()
    var audioPlayer = AVAudioPlayer()
    //播放点击的动作音效
    let hitAct = SKAction.playSoundFileNamed("hit.mp3", waitForCompletion: false)
    
    //播放背景音乐的音效
    func playBackGround(){
        let url = getLocation(musicName: "battle")
        do {
            BGMPlayer = try AVAudioPlayer(contentsOf: url, fileTypeHint: "fail")
            BGMPlayer.numberOfLoops = -1
            BGMPlayer.volume = 1
            BGMPlayer.prepareToPlay()
            BGMPlayer.play()
        } catch {
            print("file read failed!")
        }
    }
    func stopBGM() {
        BGMPlayer.stop()
    }
    
    func getLocation(musicName:String) -> URL {
        let musicPath = Bundle.main.path(forResource: musicName, ofType: "mp3")
        let url = NSURL(fileURLWithPath: musicPath!)
        return url as URL

    }
    
    //播放点击音效动作的方法
    func playHit(){
        print("播放音效!")
        self.run(hitAct)
    }
}

import Foundation
import SpriteKit

import AVFoundation

class SoundManager :SKNode{

    var BGMPlayer = AVAudioPlayer()
    var audioPlayer = AVAudioPlayer()

    let hitAct = SKAction.playSoundFileNamed("hit.mp3", waitForCompletion: false)
    
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
    
    
    func playHit(){
        print("!")
        self.run(hitAct)
    }
}

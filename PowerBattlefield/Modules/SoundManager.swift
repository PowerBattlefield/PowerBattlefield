import Foundation
import SpriteKit
import AVFoundation

class SoundManager :SKNode{

    var BGMPlayer = AVAudioPlayer()
    var audioPlayer = AVAudioPlayer()
    
    func playBackGround(){
        let url = getLocation(musicName: "battle")
        do {
            BGMPlayer = try AVAudioPlayer(contentsOf: url, fileTypeHint: "fail")
            BGMPlayer.numberOfLoops = -1
            BGMPlayer.volume = 0.2
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
    
    
    
    func playAudio(musicName: String){
        print("play" + musicName)
        let musicPath = Bundle.main.path(forResource: musicName, ofType: "wav")
        let url = NSURL(fileURLWithPath: musicPath!)
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url as URL, fileTypeHint: "fail")
            audioPlayer.numberOfLoops = 0
            audioPlayer.volume = 1
            audioPlayer.prepareToPlay()
            audioPlayer.play()
        } catch {
            print("file read failed!")
        }
    }
    
    func stopAudio(){
        audioPlayer.stop()
    }
}

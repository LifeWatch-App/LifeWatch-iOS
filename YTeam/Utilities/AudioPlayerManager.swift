//
//  AudioPlayerManager.swift
//  YTeam Watch App
//
//  Created by Kenny Jinhiro Wibowo on 26/10/23.
//

import Foundation
import AVFoundation

class AudioPlayerManager: NSObject, AVAudioPlayerDelegate, ObservableObject {
    private var audioPlayer: AVAudioPlayer = AVAudioPlayer()
    
    func playAlert(){
        let path = Bundle.main.path(forResource: "alert", ofType: "mp3")
        
        guard let path = path else {return}
        
        let url = URL(fileURLWithPath: path)
        
        guard let player = try? AVAudioPlayer(contentsOf: url) else {return}
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, options: [.mixWithOthers, .allowBluetoothA2DP])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            debugPrint("Cannot play audio session in silent mode")
        }
        
        self.audioPlayer = player
        self.audioPlayer.volume = 1
        self.audioPlayer.numberOfLoops = 10
        
        if (!self.audioPlayer.isPlaying) {
            self.audioPlayer.play()
        }
    }
    
    func stopAlert() {
        if (self.audioPlayer.isPlaying) {
            self.audioPlayer.stop()
        }
    }
}

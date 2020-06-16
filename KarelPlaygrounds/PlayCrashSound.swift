//
//  PlayCrashSound.swift
//  KarelPlaygrounds
//
//  Created by Angela Luo on 5/23/20.
//  Copyright © 2020 Angela Luo. All rights reserved.
//

import Foundation
import AVFoundation

var audioPlayer: AVAudioPlayer?

//A crash sound is played every time Karel runs into a wall or an obstacle
//Source: https://stackoverflow.com/questions/57153729/audio-not-playing-in-swiftui
func playCrashSound(sound: String, fileExtension: String) {
    if let path = Bundle.main.path(forResource: sound, ofType: fileExtension) {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
            DispatchQueue.main.async {
                audioPlayer?.play()
            }
            
        } catch {
            print("Could not play sound.")
        }
    }
}

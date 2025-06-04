//
//  SoundPlayer.swift
//  CoreMotionApp
//
//  Created by Hlwan Aung Phyo on 10/30/24.
//
import Foundation
import AVFoundation

final class SoundPlayer: NSObject, ObservableObject {
    private var bgAudioPlayer: AVAudioPlayer?
    private var fxAudioPlayer: AVAudioPlayer?
    
    static let shared = SoundPlayer()
    
    
    func playBackgroundSound(soundFileName: String, fileType: String) {
           if let path = Bundle.main.path(forResource: soundFileName, ofType: fileType) {
               let url = URL(fileURLWithPath: path)
               do {
                   bgAudioPlayer = try AVAudioPlayer(contentsOf: url)
                   bgAudioPlayer?.numberOfLoops = -1  // Loop infinitely
                   bgAudioPlayer?.volume = 0.5  // Set volume for background sound
                   bgAudioPlayer?.play()
               } catch {
                   print("Error: Couldn't play background sound file \(soundFileName).\(fileType)")
               }
           }
       }
    func playSoundEffect(soundFileName: String, fileType: String) {
            if let path = Bundle.main.path(forResource: soundFileName, ofType: fileType) {
                let url = URL(fileURLWithPath: path)
                do {
                    fxAudioPlayer = try AVAudioPlayer(contentsOf: url)
                    fxAudioPlayer?.play()
                } catch {
                    print("Error: Couldn't play sound effect file \(soundFileName).\(fileType)")
                }
            }
        }
}

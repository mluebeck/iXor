//
//  MusicBox.swift
//  iXor
//
//  Created by OSX on 23.02.17.
//  Copyright © 2017 MarioRotz. All rights reserved.
//

import UIKit
import AVFoundation

class MusicBox: NSObject,AVAudioPlayerDelegate {
  
    var backgroundMusicPlayer = AVAudioPlayer()
    var songs : [URL] = [URL]()
    var songindex = 0
    
    override init()
    {
        super.init()
        if songs.count==0
        {
            loadSongs()
        }
    }
    
    func play()
    {
        backgroundMusicPlayer.play()
    }
    
    func pause()
    {
        backgroundMusicPlayer.pause()
    }
    
    func isPlaying() -> Bool
    {
        return backgroundMusicPlayer.isPlaying
    }
      
    func stop()
    {
        backgroundMusicPlayer.stop()
    }
    
    func loadSongs() {
        let paths = Bundle.main.paths(forResourcesOfType: "mp3", inDirectory: "music")
        for path in paths {
            let url = URL.init(fileURLWithPath: path)//Bundle.main.url(forResource: path, withExtension: "mp3")
            songs.append(url)
        }
    }
    
    func playBackgroundMusic() {
//        if qaTesting==true
//        {
//            return
//        }
        do {
            print("now playing song no. \(songindex): \(songs[songindex])")
            backgroundMusicPlayer = try AVAudioPlayer(contentsOf: songs[songindex])
            backgroundMusicPlayer.delegate = self
            backgroundMusicPlayer.numberOfLoops = 0
            backgroundMusicPlayer.prepareToPlay()
            backgroundMusicPlayer.play()
        } catch let error as NSError {
            print(error.description)
        }
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool)
    {
        self.songindex += 1
        if self.songindex >= self.songs.count
        {
            self.songindex = 0
        }
        playBackgroundMusic()
    }
}

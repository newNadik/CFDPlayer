//
//  CFDProvider.swift
//  CFDPlayerView
//
//  Created by Nadiia Ivanova on 24/06/2021.
//

import UIKit
import AVFoundation
import Foundation

extension CFDPlayerView {
        
    func setup() {
        if let asset = CFDPlayerView.playIconAsset {
            centerPlayButton.setImage(UIImage(named: asset), for: .normal)
        }
        centerPlayButtonUpdate()
        addObservers()
        addBacgroundObservers()
    }
    
    func setVideo(url: String?, headers: [String: String] = [:]) {
        //let headers: [String: String] = ["Referer": GMANetwork.BASE_URL.replacingOccurrences(of: "ganbarumethod:ganbarumethod@", with: "")]
        if let url = URL(string: url ?? "") {
            setAudioSession()
            let asset = AVURLAsset(url: url, options: ["AVURLAssetHTTPHeaderFieldsKey": headers])
            let playerItem = AVPlayerItem(asset: asset)
            playerLayer.player = AVPlayer(playerItem: playerItem)
            addPlayerItemObservers(toPlayerItem: playerItem)
            addPlayerObservers()
        }
    }
    
    func setAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, mode: AVAudioSession.Mode.moviePlayback)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print(error)
        }
    }
    
    func endAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setActive(false)
        } catch {
            print(error)
        }
    }
    
    //MARK: - Actions
    @IBAction func centerPlayPressed() {
        showPlayerLayer()
        centerPlayButton.isHidden = true
        setVideo(url: videoUrl, headers: CFDPlayerView.videoUrlHeaders)
        play()
    }
        
    func play() {
        currentPlayer?.play()
    }
        
    func playerRateDidChange(rate: Float) {
        self.controlsView.playerDidUpdatePlaying?(playing: rate > 0)
    }
    
}

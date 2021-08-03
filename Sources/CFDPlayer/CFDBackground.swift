//
//  CFDBackground.swift
//  CFDPlayerView
//
//  Created by Nadiia Ivanova on 25/06/2021.
//

import Foundation
import UIKit
import MediaPlayer

extension CFDPlayerView {
    
    func addBacgroundObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidEnterBackground),
                                               name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationWillEnterForeground),
                                               name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    func setupBackgroundControls() {
        if(!pauseInBackground) {
            UIApplication.shared.beginReceivingRemoteControlEvents()
            setupCommandCenter()
        }
    }
    
    @objc func applicationDidEnterBackground() {
        if(pauseInBackground) {
            self.currentPlayer?.pause()
        } else {
            avPlayer = self.playerLayer.player
            self.playerLayer.player = nil
        }
    }
    
    @objc func applicationWillEnterForeground() {
        if(!pauseInBackground) {
            self.playerLayer.player = avPlayer
        }
    }
    
    func setupCommandCenter() {
        let duration = CMTimeGetSeconds(self.currentPlayer?.currentItem?.duration ?? CMTime.zero)
        MPNowPlayingInfoCenter.default().nowPlayingInfo = [MPMediaItemPropertyTitle: videoTitle ?? ""]
        MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPMediaItemPropertyPlaybackDuration] = duration
        MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyPlaybackRate] = self.currentPlayer?.rate
        if let urlAsset = currentPlayer?.currentItem?.asset as? AVURLAsset {
            MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyAssetURL] = urlAsset
        }
        
        let commandCenter = MPRemoteCommandCenter.shared()
        commandCenter.playCommand.isEnabled = true
        commandCenter.playCommand.addTarget { [weak self] (event) -> MPRemoteCommandHandlerStatus in
            self?.currentPlayer?.playImmediately(atRate: (self?.rate ?? 1))
            return .success
        }
        commandCenter.pauseCommand.isEnabled = true
        commandCenter.pauseCommand.addTarget { [weak self] (event) -> MPRemoteCommandHandlerStatus in
            self?.currentPlayer?.pause()
            return .success
        }
    }
    
    func removeCommandCenter() {
        MPNowPlayingInfoCenter.default().nowPlayingInfo = [:]
    }
    
}

//
//  CFDObserver.swift
//  CFDPlayerView
//
//  Created by Nadiia Ivanova on 25/06/2021.
//

import UIKit
import AVFoundation
import Foundation

extension CFDPlayerView {
    
    func addObservers() {
        NotificationCenter.default.addObserver(forName: UIDevice.orientationDidChangeNotification, object: nil, queue: nil) { [weak self] (_) in
            guard let self = self, self.fullScreenWhenLandscape, self.playerAdded() else {return}
            switch UIDevice.current.orientation {
            case .landscapeLeft:
                self.orientation = .landscapeLeft
            case .landscapeRight:
                self.orientation = .landscapeRight
            case .portrait:
                self.orientation = .protrait
            default: break
            }
        }
    }
    
    func addPlayerItemObservers(toPlayerItem playerItem: AVPlayerItem) {
        playerItem.addObserver(self, forKeyPath: KeyPath.PlayerItem.Status, options: [.initial, .new], context: nil)
        playerItem.addObserver(self, forKeyPath: KeyPath.PlayerItem.PlaybackLikelyToKeepUp, options: [.initial, .new], context: nil)
        playerItem.addObserver(self, forKeyPath: KeyPath.PlayerItem.LoadedTimeRanges, options: [.initial, .new], context: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.didFinishPlaying),
                                               name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)
    }
    
    func removePlayerItemObservers(fromPlayerItem playerItem: AVPlayerItem) {
        playerItem.removeObserver(self, forKeyPath: KeyPath.PlayerItem.Status, context: nil)
        playerItem.removeObserver(self, forKeyPath: KeyPath.PlayerItem.PlaybackLikelyToKeepUp, context: nil)
        playerItem.removeObserver(self, forKeyPath: KeyPath.PlayerItem.LoadedTimeRanges, context: nil)
    }
    
    func addPlayerObservers() {
        
        self.currentPlayer?.addObserver(self, forKeyPath: KeyPath.Player.Rate, options: [.initial, .new], context: nil)
        let interval = CMTimeMakeWithSeconds(0.1, preferredTimescale: Int32(NSEC_PER_SEC))
        self.playerTimeObserver = self.currentPlayer?.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main, using: { [weak self] (cmTime) in
            if let strongSelf = self, let time = cmTime.timeInterval {
                strongSelf.time = time
            }
        })
    }
    
    func removePlayerObservers() {
        self.currentPlayer?.removeObserver(self, forKeyPath: KeyPath.Player.Rate, context: nil)
        if let playerTimeObserver = self.playerTimeObserver {
            self.currentPlayer?.removeTimeObserver(playerTimeObserver)
            self.playerTimeObserver = nil
        }
    }
    
    override open func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == KeyPath.PlayerItem.Status {
            if let statusInt = change?[.newKey] as? Int, let status = AVPlayerItem.Status(rawValue: statusInt) {
                self.playerItemStatusDidChange(status: status)
            }
        }
        else if keyPath == KeyPath.PlayerItem.PlaybackLikelyToKeepUp {
            if let playbackLikelyToKeepUp = change?[.newKey] as? Bool {
                self.playerItemPlaybackLikelyToKeepUpDidChange(playbackLikelyToKeepUp: playbackLikelyToKeepUp)
            }
        }
        else if keyPath == KeyPath.PlayerItem.LoadedTimeRanges {
            if let loadedTimeRanges = change?[.newKey] as? [NSValue] {
                self.playerItemLoadedTimeRangesDidChange(loadedTimeRanges: loadedTimeRanges)
            }
        }
        
        // Player Observers
        else if keyPath == KeyPath.Player.Rate {
            if let rate = change?[.newKey] as? Float {
                self.playerRateDidChange(rate: rate)
            }
        }
        
        // Fall Through Observers
        else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    @objc func didFinishPlaying() {
        removePlayerLayer()
        centerPlayButton.isHidden = false
    }
    
    // MARK: - Observation Helpers
    func playerItemStatusDidChange(status: AVPlayerItem.Status) {
        switch status {
        case .unknown:
            self.state = .loading
            break
        case .readyToPlay:
            self.state = .ready
            break
        case .failed:
            self.state = .failed
            break
        default:
            self.state = .failed
            break
        }
    }
    
    func playerItemPlaybackLikelyToKeepUpDidChange(playbackLikelyToKeepUp: Bool) {
        let state: PlayerState = playbackLikelyToKeepUp ? .ready : .loading
        self.state = state
    }
    
    func playerItemLoadedTimeRangesDidChange(loadedTimeRanges: [NSValue]) {
        guard let bufferedCMTime = loadedTimeRanges.first?.timeRangeValue.end, let bufferedTime = bufferedCMTime.timeInterval else {
            return
        }
        self.bufferedTime = bufferedTime
    }
    
    func removeAllObserver() {
        NotificationCenter.default.removeObserver(self)
        if let playerItem = currentPlayer?.currentItem {
            removePlayerItemObservers(fromPlayerItem: playerItem)
        }
    }

}

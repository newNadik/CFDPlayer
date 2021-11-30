//
//  CFDPlayerView.swift
//  CFDPlayerView
//
//  Created by Nadiia Ivanova on 24/06/2021.
//

import UIKit
import AVFoundation

@IBDesignable
public class CFDPlayerView: UIView {
    
    public static var videoUrlHeaders: [String: String] = [:]
    public static var accentColor: UIColor = UIColor.systemBlue
    public static var playIconAsset: String?
    
    public var videoTitle: String?
    public var videoUrl: String? {
        didSet {
            centerPlayButtonUpdate()
        }
    }
        
    public func setCover(_ image: UIImage) {
        coverImageView.image = image
        playerLayer.backgroundColor = UIColor.black.cgColor
    }
    
    lazy var controlsView: UIView & CFDPlayerControlsProtocol = {
        let controls = CFDPlayerControls()
        controls.playLayer = self
        return controls
    }()
    
    public var fullScreenWhenLandscape = true
    public var pauseInBackground = false
    
    public var currentPlayer: AVPlayer? {
        set {
            playerLayer.player = newValue
            avPlayer = newValue
        }
        get {
            return playerLayer.player ?? avPlayer
        }
    }    
    
    weak open var delegate: CFDPlayerDelegate?
    
    public func seekTo(to time: CMTime, completionHandler: @escaping (Bool) -> Void) {
        self.playerLayer.player?.seek(to: time) { finish in
            self.controlsView.playerDidUpdateTime?(time: time.timeInterval ?? 0)
            completionHandler(finish)
        }
    }
    
    public func seekBy(by offset: Int, completionHandler: @escaping (Bool) -> Void) {
        let totalDuration = playerLayer.player?.currentItem?.duration.seconds ?? 0
        let position = time + TimeInterval(offset)
        let time = max(0, min(totalDuration, position))
        self.seekTo(to: CMTimeMake(value: Int64(time), timescale: 1)) { finish in
            completionHandler(finish)
        }
    }
    
    public func playPauseAction() {
        self.delayHideControls()
        if playerLayer.player?.rate == 0 {
            self.playerLayer.player?.playImmediately(atRate: rate)
        } else {
            self.playerLayer.player?.pause()
        }
    }
        
    public var autoHideCoverType = CoverAutoHideType.autoHide(after: 3.0) {
        didSet {
            switch autoHideCoverType {
            case .disable:
                NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(CFDPlayerView.showControls(isShow:)), object: nil)
            case .autoHide(let after):
                self.perform(#selector(CFDPlayerView.showControls(isShow:)), with: nil, afterDelay: after)
            }
        }
    }    
    
    //MARK: - private
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var centerPlayButton: UIButton!
    @IBOutlet weak var contentView: UIView!
    var isControlsShow = false
    
    var playerContainer: UIView? {
        willSet {
            bgView.removeFromSuperview()
            playerContainer?.removeGestureRecognizer(tapGesture)
        } didSet {
            guard let new = playerContainer else {
                return
            }
            new.addSubview(self.bgView)
            self.layoutSubviews()
            new.isUserInteractionEnabled = true
            new.addGestureRecognizer(tapGesture)
        }
    }
    lazy var bgView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.clear
        return v
    }()
    
    var playerLayer = AVPlayerLayer()
    var avPlayer: AVPlayer?
    
    var orientation: PlayerOrientation = .protrait {
        didSet {
            self.landscapeWindow.update()
        }
    }
    
    lazy var tapGesture: UITapGestureRecognizer = {
        let g = UITapGestureRecognizer(target: self, action: #selector(CFDPlayerView.touchAction(gesture:)))
        return g
    }()
    
    lazy var landscapeWindow: CFDLandscapeWindow = {
        let window = CFDLandscapeWindow(playerLayer: self)
        return window
    }()
    
    var playerTimeObserver: Any?
    var state: PlayerState = .ready {
        didSet {
            if(state == .ready && oldValue == .loading) {
                addControlsView()
                setupBackgroundControls()
            }
        }
    }
    
    var time: TimeInterval = 0 {
        didSet {
            controlsView.playerDidUpdateTime?(time: time)
        }
    }
    
    var rate: Float = 1 {
        didSet {
            currentPlayer?.rate = rate
            controlsView.playerDidUpdateRate?(rate: rate)
        }
    }
    
    var bufferedTime: TimeInterval = 0 {
        didSet {
            controlsView.playerDidUpdateBufferedTime?(buffered: bufferedTime)
        }
    }
    
    func playerAdded() -> Bool {
        return playerLayer.player != nil
    }
    
    //MARK: - init
    override init(frame: CGRect) {
        super.init(frame: frame)
        xibSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        xibSetup()
    }
    
    public override func removeFromSuperview() {
        currentPlayer?.pause()
        currentPlayer?.replaceCurrentItem(with: nil)
        playerLayer.removeFromSuperlayer()
        currentPlayer = nil
        
        self.removeAllObserver()
        self.removePlayerObservers()
        self.removeCommandCenter()
        self.endAudioSession()
        super.removeFromSuperview()
    }
    
}

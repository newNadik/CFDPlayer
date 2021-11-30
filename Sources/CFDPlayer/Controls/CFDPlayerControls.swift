//
//  CFDPlayerControls.swift
//  CFDPlayerView
//
//  Created by Nadiia Ivanova on 25/06/2021.
//

import UIKit
import AVFoundation

class CFDPlayerControls: UIView, CFDPlayerControlsProtocol {
    
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var progressSlider: CFDCustomSlider!
    @IBOutlet weak var bufferProgressView: UIProgressView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var remainTimeLabel: UILabel!
    @IBOutlet weak var speedSelectionView: UIView!
    @IBOutlet weak var speedButton: UIButton!
    
    var playLayer: CFDPlayerView? {
        didSet {
            self.playPauseButton?.isSelected = (playLayer?.currentPlayer?.rate ?? 0) > 0
        }
    }
    var isUpdateTime = false
    var isSpeedControlsShow = false
    
    func playerDidUpdatePlaying(playing: Bool) {
        self.playPauseButton.isSelected = playing
    }
    
    func playerDidUpdateTime(time: TimeInterval) {
        if(!isUpdateTime) {
            self.currentTimeUpdate(time: time)
            if let totalTime = playLayer?.currentPlayer?.currentItem?.duration.timeInterval {
                self.progressUpdate(value: Float(time / totalTime))
                self.remainTimeLabel.text = "-\((totalTime-time).convertSecondString())"
            }
        }
    }
    
    func playerDidUpdateBufferedTime(buffered: TimeInterval) {
        if let totalTime = playLayer?.currentPlayer?.currentItem?.duration.timeInterval {
            self.bufferUpdate(value: Float(buffered / totalTime))
        }
    }
    
    func playerDidUpdateRate(rate: Float) {
        let formatter = NumberFormatter()
        formatter.positiveFormat = "0.##"
        formatter.string(from: NSNumber(value: rate))
        let rateStr = "x\(formatter.string(from: NSNumber(value: rate)) ?? "1")"
        speedButton.setTitle(rateStr, for: .normal)
    }
    
    func progressUpdate(value: Float) {
        progressSlider.value = value
    }
    
    func bufferUpdate(value: Float) {
        bufferProgressView.progress = value
    }
    
    func currentTimeUpdate(time: TimeInterval) {
        self.timeLabel.text = time.convertSecondString()
    }
    
    //MARK: - Actions
    @IBAction func playPausePressed() {
        self.playLayer?.playPauseAction()
    }
    
    @IBAction func forwardPressed() {
        self.playLayer?.delayHideControls()
        self.playLayer?.seekBy(by: 15) { finish in }
    }
    
    @IBAction func backwardPressed() {
        self.playLayer?.delayHideControls()
        self.playLayer?.seekBy(by: -15) { finish in }
    }
    
    @IBAction func speedPressed() {
        showSpeedControls(isShow: !isSpeedControlsShow)
    }
    
    @IBAction func didSelectSpeed(sender: UIButton) {
        var newSpeedValue: Float = 1
        switch sender.tag {
        case 1:
            newSpeedValue = 0.75
            break
        case 2:
            newSpeedValue = 1
            break
        case 3:
            newSpeedValue = 1.5
            break
        case 4:
            newSpeedValue = 2
            break
        default:
            newSpeedValue = 1
        }
        self.playLayer?.rate = newSpeedValue
        self.showSpeedControls(isShow: false)
    }
    
    public func delayHideSpeedControls() {
        self.showSpeedControls(isShow: true)
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(showSpeedControls(isShow:)), object: nil)
        self.perform(#selector(showSpeedControls(isShow:)), with: nil, afterDelay: 3)
    }
    
    @objc func showSpeedControls(isShow: Bool) {
        self.isSpeedControlsShow = isShow
        if isShow {
            NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(showSpeedControls(isShow:)), object: nil)
            self.perform(#selector(showSpeedControls(isShow:)), with: nil, afterDelay: 3)
        }
        if(isShow) {
            self.speedSelectionView.alpha = 0
            self.speedSelectionView.isHidden = false
        }
        UIView.animate(withDuration: 0.1, animations: { [weak self] in
            self?.speedSelectionView.alpha = (isShow) ? 1.0 : 0.0
        }) { _ in
            self.speedSelectionView.isHidden = !isShow
        }
    }
    
    @IBAction func sliderValueChange(slider: UISlider) {
        self.isUpdateTime = true
        self.playLayer?.delayHideControls()
        if let totalTime = playLayer?.currentPlayer?.currentItem?.duration.timeInterval {
            let seconds = Float(totalTime) * self.progressSlider.value
            self.currentTimeUpdate(time: TimeInterval(seconds))
        }
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(delaySeekTime), object: nil)
        self.perform(#selector(delaySeekTime), with: nil, afterDelay: 0.1)
    }
    
    @objc func delaySeekTime() {
        if let totalTime = playLayer?.currentPlayer?.currentItem?.duration.timeInterval {
            let seconds = Float(totalTime) * self.progressSlider.value
            let time = CMTimeMake(value: Int64(seconds), timescale: 1)
            self.playLayer?.seekTo(to: time, completionHandler: { finish in
                self.isUpdateTime = false
            })
        }
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
    
    func xibSetup() {
        let view = loadViewFromNib()
        view.frame = bounds
        view.autoresizingMask = [UIView.AutoresizingMask.flexibleWidth, UIView.AutoresizingMask.flexibleHeight]
        addSubview(view)
        progressSlider.minimumTrackTintColor = CFDPlayerView.accentColor
    }
    
    func loadViewFromNib() -> UIView {
        let nib = UINib(nibName: "CFDPlayerControls", bundle: Bundle.module)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        return view
    }
}

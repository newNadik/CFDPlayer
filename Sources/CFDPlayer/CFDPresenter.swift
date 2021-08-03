//
//  CFDPresenter.swift
//  CFDPlayerView
//
//  Created by Nadiia Ivanova on 24/06/2021.
//

import UIKit
import AVFoundation
import Foundation

extension CFDPlayerView {
           
    func xibSetup() {
        let view = loadViewFromNib()
        view.frame = bounds
        view.autoresizingMask = [UIView.AutoresizingMask.flexibleWidth, UIView.AutoresizingMask.flexibleHeight]
        addSubview(view)
        setup()
    }
    
    func loadViewFromNib() -> UIView {
        let nib = UINib(nibName: "CFDPlayerView", bundle: Bundle.module)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        return view
    }
    
    func centerPlayButtonUpdate() {
        centerPlayButton.isHidden = videoUrl?.isEmpty ?? true
    }
    
    @objc func touchAction(gesture: UITapGestureRecognizer) {
        switch self.state {
        case .failed:
            return
        default: break
        }
        
        if let p = self.playerContainer {
            let point = gesture.location(in: p)
            if self.playerLayer.videoRect.isEmpty || self.playerLayer.videoRect.contains(point) {
                self.showControls(isShow: !self.isControlsShow)
            }
        }
    }
    
    public func delayHideControls() {
        self.showControls(isShow: true)
        switch self.autoHideCoverType {
        case .autoHide(let after):
            NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(CFDPlayerView.showControls(isShow:)), object: nil)
            self.perform(#selector(CFDPlayerView.showControls(isShow:)), with: nil, afterDelay: after)
        default:
            break
        }
    }
    
    @objc func showControls(isShow: Bool) {
        self.isControlsShow = isShow
        if isShow {
            switch self.autoHideCoverType {
            case .autoHide(let after):
                NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(CFDPlayerView.showControls(isShow:)), object: nil)
                self.perform(#selector(CFDPlayerView.showControls(isShow:)), with: nil, afterDelay: after)
            default: break
            }
        }

        if(self.controlsView.responds(to: #selector( self.controlsView.controlsView(isShow:)))) {
            self.controlsView.controlsView!(isShow: isShow)
            return
        }

        UIView.animate(withDuration: 0.2, animations: { [weak self] in
            self?.controlsView.alpha = (isShow) ? 1.0 : 0.0
        })
    }
    
    func showPlayerLayer() {
        self.bgView.layer.addSublayer(playerLayer)
        playerLayer.backgroundColor = UIColor.black.cgColor
        self.playerContainer = self.contentView
        
        self.delayHideControls()
        layoutSubviews()
    }
    
    func removePlayerLayer() {
        playerLayer.removeFromSuperlayer()
        controlsView.removeFromSuperview()
        self.playerContainer = nil
    }
    
    func addControlsView() {
        self.bgView.addSubview(self.controlsView)
        layoutSubviews()
    }
    
    func fitContent() {
        bgView.frame = bgView.superview?.bounds ?? CGRect.zero
        playerLayer.frame = bgView.bounds
        controlsView.frame = minFrame(bgView.bounds, landscapeWindow.safeAreaLayoutGuide.layoutFrame)
    }
    
    func minFrame(_ a: CGRect, _ b: CGRect) -> CGRect {
        let isLand = a.width > a.height
        var bWidth = b.width
        var bHeight = b.height
        if(isLand) {
            bWidth = max(b.width, b.height)
            bHeight = min(b.width, b.height)
        }
        if(a.width < bWidth && a.height < b.height) {
            return a
        } else {
            var bx = b.origin.x
            var by = b.origin.y
            if(bWidth != b.width) {
                bx = b.origin.y
                by = b.origin.x
            }
            return CGRect(x: bx, y: by, width: bWidth, height: bHeight)
        }
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        fitContent()
    }
    
}

//
//  CFDLandscapeWindow.swift
//  CFDPlayerView
//
//  Created by Nadiia Ivanova on 24/06/2021.
//

import Foundation
import UIKit

private class WindowViewController: UIViewController {
    var isStatusHidden = false
    
    override var prefersStatusBarHidden: Bool {
        return isStatusHidden
    }
}

public class CFDLandscapeWindow: UIWindow {
    unowned let playerView: CFDPlayerView
    weak var originalPlayView: UIView?
    var completed: (()->Void)?
    
    public init(playerLayer: CFDPlayerView) {
        self.playerView = playerLayer
        if let currentWindowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            super.init(windowScene: currentWindowScene)
        } else {
            super.init(frame: UIScreen.main.bounds)
        }
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func layoutSubviews() {
        super.layoutSubviews()
        self.frame = UIScreen.main.bounds
        self.update()
    }
    
}

extension CFDLandscapeWindow {
    private func setup() {
        self.rootViewController = WindowViewController()
        self.backgroundColor = UIColor.black
        self.windowLevel = UIWindow.Level.alert
    }

    func update() {
        switch self.playerView.orientation {
        case .protrait:
            (self.rootViewController as? WindowViewController)?.isStatusHidden = false
            if let o = self.originalPlayView {                
                UIView.animate(withDuration: 0.3, animations: {
                    self.backgroundColor = UIColor.clear
                    self.rootViewController?.view.layer.transform = CATransform3DIdentity
                    self.rootViewController?.view.frame = o.superview?.convert(o.frame, to: self) ?? .zero
                    self.playerView.layoutSubviews()
                }) { [weak self] (_) in
                    self?.playerView.playerContainer = o
                    self?.originalPlayView = nil
                    self?.isHidden = true
                }
            }
        case .landscapeRight, .landscapeLeft:
            (self.rootViewController as? WindowViewController)?.isStatusHidden = true
            if !self.isPlayOnSelf {
                self.isHidden = false
                self.originalPlayView = self.playerView.playerContainer
                self.makeKeyAndVisible()
                self.playerView.playerContainer = self.rootViewController?.view
            }
            let parameter: CGFloat = UIDevice.current.orientation == .landscapeRight ? -1 : 1
            let isLand = UIScreen.main.bounds.width > UIScreen.main.bounds.height
            UIView.animate(withDuration: 0.3, animations: {
                if !isLand {
                    let transform = CATransform3DRotate(CATransform3DIdentity, parameter*CGFloat.pi/2, 0, 0, 1)
                    self.rootViewController?.view.layer.transform = transform
                    self.backgroundColor = UIColor.black
                } else {
                    self.rootViewController?.view.layer.transform = CATransform3DIdentity
                }
                self.rootViewController?.view.frame = UIScreen.main.bounds
                self.playerView.layoutSubviews()
            })
        }
    }
    
    private var isPlayOnSelf: Bool {
        return self.playerView.playerContainer == self.rootViewController?.view
    }
    
}

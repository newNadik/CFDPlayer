//
//  CFDPlayerControlsProtocol.swift
//  CFDPlayerView
//
//  Created by Nadiia Ivanova on 25/06/2021.
//

import Foundation

@objc public protocol CFDPlayerControlsProtocol: AnyObject {
    
    weak var playLayer: CFDPlayerView? { set get }
    
    @objc optional func playerDidUpdatePlaying(playing: Bool)
    @objc optional func playerDidUpdateTime(time: TimeInterval)
    @objc optional func playerDidUpdateRate(rate: Float)
    @objc optional func playerDidUpdateBufferedTime(buffered: TimeInterval)
    @objc optional func controlsView(isShow: Bool)
    
}

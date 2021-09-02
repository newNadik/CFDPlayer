//
//  CFDPlayerDelegate.swift
//  
//
//  Created by Nadiia Ivanova on 02/09/2021.
//

import Foundation

@objc public protocol CFDPlayerDelegate: NSObjectProtocol {
 
    func playerDidFinishPlaying(_ playerView: CFDPlayerView)

}

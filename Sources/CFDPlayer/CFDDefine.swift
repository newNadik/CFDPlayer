//
//  CFDDefine.swift
//  CFDPlayerView
//
//  Created by Nadiia Ivanova on 24/06/2021.
//

import Foundation
import AVFoundation
import UIKit

public enum PlayerOrientation: Int {
    case landscapeLeft
    case landscapeRight
    case protrait
}

public enum PlayerState: Int {
    case loading
    case ready
    case failed
}

public struct KeyPath {
    struct Player {
        static let Rate = "rate"
    }
    
    struct PlayerItem {
        static let Status = "status"
        static let PlaybackLikelyToKeepUp = "playbackLikelyToKeepUp"
        static let LoadedTimeRanges = "loadedTimeRanges"
    }
}

public enum CoverAutoHideType {
    case autoHide(after: TimeInterval)
    case disable
    
    var delay: TimeInterval {
        get {
            switch self {
            case .autoHide(let after):
                return after
            case .disable:
                return 0
            }
        }
    }
}

public extension CMTime {
    var timeInterval: TimeInterval? {
        if CMTIME_IS_INVALID(self) || CMTIME_IS_INDEFINITE(self) {
            return nil
        }
        
        return CMTimeGetSeconds(self)
    }
}

extension TimeInterval {
    func convertSecondString() -> String {
        let component =  Date.dateComponentFrom(second: self)
        if let hour = component.hour ,
            let min = component.minute ,
            let sec = component.second {
            
            let fix =  hour > 0 ? NSString(format: "%02d:", hour) : ""
            let a = NSString(format: "%@%02d:%02d", fix,min,sec) as String
            return a
        } else {
            return "-:-"
        }
    }
}

extension Date {
    static func dateComponentFrom(second: Double) -> DateComponents {
        let interval = TimeInterval(second)
        let date1 = Date()
        let date2 = Date(timeInterval: interval, since: date1)
        let c = NSCalendar.current
        
        var components = c.dateComponents([.year,.month,.day,.hour,.minute,.second,.weekday], from: date1, to: date2)
        components.calendar = c
        return components
    }
}

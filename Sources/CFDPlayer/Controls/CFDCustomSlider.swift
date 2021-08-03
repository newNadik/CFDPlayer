//
//  CFDCustomSlider.swift
//  CFDPlayerView
//
//  Created by Nadiia Ivanova on 25/06/2021.
//

import Foundation
import UIKit

class CFDCustomSlider: UISlider {
    
    @IBInspectable var thumbRadius: CGFloat = 10
    @IBInspectable open var trackWidth: CGFloat = 2 {
        didSet { setNeedsDisplay() }
    }
    
    override open func trackRect(forBounds bounds: CGRect) -> CGRect {
        let defaultBounds = super.trackRect(forBounds: bounds)
        
        return CGRect(
            x: defaultBounds.origin.x,
            y: defaultBounds.origin.y + defaultBounds.size.height/2 - trackWidth/2,
            width: defaultBounds.size.width,
            height: trackWidth
        )
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let thumb = thumbImage(radius: thumbRadius)
        setThumbImage(thumb, for: .normal)
        isContinuous = true
    }
    
    private func thumbImage(radius: CGFloat) -> UIImage {
        let thumbView = UIView()
        thumbView.backgroundColor = UIColor.white
        thumbView.frame = CGRect(x: 0, y: radius / 2, width: radius, height: radius)
        thumbView.layer.cornerRadius = radius / 2
        
        let renderer = UIGraphicsImageRenderer(bounds: thumbView.bounds)
        return renderer.image { rendererContext in
            thumbView.layer.render(in: rendererContext.cgContext)
        }
    }
    
}

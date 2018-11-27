//
//  EnlargedThumbSlider.swift
//  poly_player
//
//  Created by Hiroteru Watanabe on 2018/11/04.
//  Copyright © 2018 Hiroteru Watanabe. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
open class EnlargedThumbSlider: UISlider {
    
    private var thumbView: UIImageView = UIImageView()
    private var thumbImageView: UIImageView = UIImageView()
    private var thumbOuterView: UIImageView = UIImageView()
    
    private var normalThumbImage: UIImage?
    private var highlightedThumbImage: UIImage?
    private let normalThumbSize: CGSize = CGSize(width: 8, height: 8)
    private let highlightedThumbRadius: CGFloat = 14
    private let highlightedThumbSize: CGSize = CGSize(width: 28, height: 28)
    private let thumbOuterSize: CGSize = CGSize(width: 32, height: 32)
    
    
    /// The tint color of minimum track for normal state.
    @IBInspectable
    open private(set) var minimumTrackTintColorForNormal: UIColor?
    
    /// The tint color of minimum track for highlighted state.
    @IBInspectable
    open private(set) var minimumTrackTintColorForHighlighted: UIColor?
    
    /// Specifies the duration of enlarging thumb or shrinking thumb animation, in seconds.
    @IBInspectable
    open var thumbAnimationDuration: CFTimeInterval = 0.3
    
    
    /// The color of thumb's circle image for normal state.
    @IBInspectable
    open var normalThumbColor: UIColor = .white {
        didSet {
            if state == .normal {
                thumbImageView.tintColor = normalThumbColor
            }
        }
    }
    
    
    /// The color of the thumb's circle image for highlighted state.
    @IBInspectable
    open var highlightedThumbColor: UIColor = .white {
        didSet {
            if state == .highlighted {
                thumbImageView.tintColor = highlightedThumbColor
            }
        }
    }
    
    
    /// The color of the outer side of the thumb's circle image.  The outer side of the thumb's circle image is visible only when the slider is highlighted.
    @IBInspectable
    open var thumbOuterColor: UIColor = .white {
        didSet {
            thumbOuterView.tintColor = thumbOuterColor
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        thumbView.backgroundColor = .clear
        thumbView.frame.size = normalThumbSize
        thumbImageView.frame.size = normalThumbSize
        thumbImageView.tintColor = normalThumbColor
        addSubview(thumbView)
        thumbView.addSubview(thumbImageView)
        thumbOuterView.image = thumbOuter(color: thumbOuterColor)
        thumbOuterView.tintColor = thumbOuterColor
    }
    
    override open func setThumbImage(_ image: UIImage?, for state: UIControlState) {
        if self.state == state {
            thumbImageView.image = image
        }
        if state == .normal {
            super.setThumbImage(image, for: state)
        }
    }
    
    override open func thumbRect(forBounds bounds: CGRect, trackRect rect: CGRect, value: Float) -> CGRect {
        let frame = super.thumbRect(forBounds: bounds, trackRect: rect, value: value)

        guard bounds.contains(rect) else {
            return frame
        }
        thumbView.center = CGPoint(x: frame.midX, y: frame.midY)
        bringSubview(toFront: thumbView)
        return frame
    }
    
    override open var isHighlighted: Bool {
        get {
            return super.isHighlighted
        }
        set {
            let oldValue = super.isHighlighted
            if isTracking {
                super.isHighlighted = true
            } else {
                super.isHighlighted = false
            }
            
            if isHighlighted {
                if !oldValue {
                    enlargeThumb()
                    minimumTrackTintColor = minimumTrackTintColorForHighlighted
                }
            } else {
                if oldValue {
                    shrinkThumb()
                    minimumTrackTintColor = minimumTrackTintColorForNormal
                }
            }
        }
    }
    
    private func circleImage(color: UIColor, circleSize: CGSize, imageSize: CGSize? = nil) -> UIImage {
        let imageSize = imageSize ?? circleSize
        let thumbLayer = CAShapeLayer()
        thumbLayer.fillColor = color.cgColor
        thumbLayer.frame = CGRect(origin: .zero, size: imageSize)
        thumbLayer.path = UIBezierPath(ovalIn: CGRect(origin: CGPoint(x: thumbLayer.frame.midX - circleSize.width / 2, y: thumbLayer.frame.midY - circleSize.height / 2), size: circleSize)).cgPath
        
        let renderer = UIGraphicsImageRenderer(bounds: thumbLayer.bounds)
        let circleImage = renderer.image(actions: { (context) in
            thumbLayer.render(in: context.cgContext)
        })
        
        return circleImage.withRenderingMode(.alwaysTemplate)
    }
    
    private func thumbOuter(color: UIColor) -> UIImage {
        return circleImage(color: color, circleSize: thumbOuterSize)
    }
    
    private func circleThumb(color: UIColor, for state: UIControl.State) -> UIImage? {
        switch state {
        case .normal:
            return circleImage(color: color, circleSize: normalThumbSize)
        case .highlighted:
            return circleImage(color: color, circleSize: highlightedThumbSize, imageSize: thumbOuterSize)
        default:
            return nil
        }
    }
    
    
    /// Assigns a circle color of the thumb to the specified control states.
    ///
    /// - Parameters:
    ///   - color: The circle color of the thumb to associate with the specified states.
    ///   - state: The control state with which to associate the circle color.
    open func setCircleThumb(color: UIColor, for state: UIControl.State) {
        guard let thumb = circleThumb(color: color, for: state) else { return }
        
        switch state {
        case .normal:
            normalThumbImage = thumb
            normalThumbColor = color
        case .highlighted:
            highlightedThumbImage = thumb
            highlightedThumbColor = color
        default:
            return
        }
        
        setThumbImage(thumb, for: state)
    }
    
    
    /// Assigns a minimum track color to the specified control states.
    ///
    /// - Parameters:
    ///   - minimumTrackTintColor: The minimum track color to associate with the specified states.
    ///   - state: The control state with which to associate the color.
    open func setMinimumTrackTintColor(_ minimumTrackTintColor: UIColor, for state: UIControl.State) {
        switch state {
        case .normal:
            minimumTrackTintColorForNormal = minimumTrackTintColor
        case .highlighted:
            minimumTrackTintColorForHighlighted = minimumTrackTintColor
        default:
            break
        }
        
        if isHighlighted {
            self.minimumTrackTintColor = minimumTrackTintColorForHighlighted
        } else {
            self.minimumTrackTintColor = minimumTrackTintColorForNormal
        }
    }
    
    private func enlargeThumb() {
        let thumbCenter = thumbView.center
        thumbView.frame.size = thumbOuterSize
        thumbView.center = thumbCenter
        
        thumbOuterView.transform = CGAffineTransform.identity
        thumbView.insertSubview(thumbOuterView, belowSubview: thumbImageView)
        thumbOuterView.frame.size = normalThumbSize
        thumbOuterView.center = CGPoint(x: thumbView.frame.width / 2, y: thumbView.frame.height / 2)
        thumbImageView.tintColor = highlightedThumbColor
        thumbImageView.center = CGPoint(x: thumbView.frame.width / 2, y: thumbView.frame.height / 2)
        
        UIView.animate(withDuration: thumbAnimationDuration, delay: 0, options: [.curveEaseOut], animations: {
            self.thumbImageView.frame.size = self.thumbOuterSize
            self.thumbImageView.frame.origin = .zero
            self.thumbImageView.image = self.highlightedThumbImage
            self.thumbOuterView.transform = CGAffineTransform(scaleX: self.thumbOuterSize.width / self.normalThumbSize.width, y: self.thumbOuterSize.height / self.normalThumbSize.height)
            
        })

    }
    
    private func shrinkThumb() {
        let thumbCenter = thumbView.center
        thumbImageView.tintColor = normalThumbColor
        UIView.animate(withDuration: thumbAnimationDuration, delay: 0, options: [.curveEaseOut], animations: {
            self.thumbView.frame.size = self.normalThumbSize
            self.thumbView.center = thumbCenter
            self.thumbImageView.frame.size = self.normalThumbSize
            self.thumbImageView.frame.origin = .zero
            self.thumbImageView.image = self.normalThumbImage
            self.thumbOuterView.removeFromSuperview()
        })
    }
   
}

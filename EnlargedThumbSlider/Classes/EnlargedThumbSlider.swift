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
  
  private var thumbView = UIView()
  private var thumbImageView = UIImageView()
  private var thumbOuterView = UIImageView()
  private var isThumbEnlarged = false
  
  private var normalThumbImage: UIImage?
  private var highlightedThumbImage: UIImage?
  private let normalThumbRadius: CGFloat = 4
  private var normalThumbSize: CGSize {
    return CGSize(width: normalThumbRadius * 2, height: normalThumbRadius * 2)
  }
  private let highlightedThumbRadius: CGFloat = 14
  private var highlightedThumbSize: CGSize {
    return CGSize(width: 28, height: 28)
  }
  private let thumbOuterRadius: CGFloat = 16
  private var thumbOuterSize: CGSize {
    return CGSize(width: thumbOuterRadius * 2, height: thumbOuterRadius * 2)
  }
  
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
  
  override public init(frame: CGRect) {
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
    super.setThumbImage(circleThumb(color: .clear, for: state), for: state)
    setCircleThumb(color: normalThumbColor, for: .normal)
    setCircleThumb(color: highlightedThumbColor, for: .highlighted)
    setMinimumTrackTintColor(highlightedThumbColor, for: .highlighted)
  }
  
  private var percent: CGFloat {
    guard abs(minimumValue) + abs(maximumValue) > 0 else { return 0 }
    return CGFloat(value + abs(minimumValue)) / CGFloat(abs(minimumValue) + abs(maximumValue))
  }
  
  override open func setThumbImage(_ image: UIImage?, for state: UIControl.State) {
    if self.state == state {
      thumbImageView.image = image
    }
    super.setThumbImage(UIImage(), for: state)
  }
  
  override open func thumbRect(forBounds bounds: CGRect, trackRect rect: CGRect, value: Float) -> CGRect {
    let frame = super.thumbRect(forBounds: bounds, trackRect: rect, value: value)
    
    guard bounds.contains(rect) else { return frame }
    bringSubviewToFront(thumbView)
    
    if isHighlighted || isThumbEnlarged {
      thumbView.frame.origin = enlargedThumbRect(for: frame).origin
    } else {
      thumbView.center = CGPoint(x: frame.midX, y: frame.midY)
    }
    
    return frame
  }
  
  func enlargedThumbRect(for thumbRect: CGRect) -> CGRect {
    let origin = CGPoint(x: thumbRect.origin.x - (highlightedThumbRadius - normalThumbRadius) * 2 * percent, y: thumbRect.midY - thumbOuterRadius)
    return CGRect(origin: origin, size: highlightedThumbSize)
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
    let thumbFrame = super.thumbRect(forBounds: bounds, trackRect: trackRect(forBounds: bounds), value: value)
    thumbView.frame.origin = thumbFrame.origin
    thumbView.insertSubview(thumbOuterView, belowSubview: thumbImageView)
    thumbOuterView.frame.size = normalThumbSize
    thumbOuterView.center = CGPoint(x: thumbView.frame.width / 2, y: thumbView.frame.height / 2)
    thumbImageView.tintColor = highlightedThumbColor
    thumbImageView.center = CGPoint(x: thumbView.frame.width / 2, y: thumbView.frame.height / 2)
    
    UIView.animate(withDuration: thumbAnimationDuration, delay: 0, options: [.curveEaseOut], animations: { [weak self] in
      guard let self = self else { return }
      self.thumbView.frame.origin = self.enlargedThumbRect(for: thumbFrame).origin
      self.thumbView.frame.size = self.highlightedThumbSize
      self.thumbImageView.frame.size = self.thumbOuterSize
      self.thumbImageView.frame.origin = .zero
      self.thumbImageView.image = self.highlightedThumbImage
      self.thumbOuterView.frame.origin = .zero
      self.thumbOuterView.frame.size = self.thumbOuterSize
      }, completion: { [weak self] _ in
        guard let self = self else { return }
        guard self.thumbOuterView.superview != nil else { return }
        self.isThumbEnlarged = true
    })
  }
  
  private func shrinkThumb() {
    isThumbEnlarged = false
    let thumbCenter = thumbView.center
    thumbImageView.tintColor = normalThumbColor
    UIView.animate(withDuration: thumbAnimationDuration, delay: 0, options: [.curveEaseOut], animations: {
      self.thumbView.frame.size = self.normalThumbSize
      self.thumbView.center = thumbCenter
      self.thumbImageView.frame.size = self.normalThumbSize
      self.thumbImageView.frame.origin = .zero
      self.thumbImageView.image = self.normalThumbImage
      self.thumbOuterView.removeFromSuperview()
    }, completion: { [weak self] _ in
      self?.isThumbEnlarged = false
    })
  }
  
  override open func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
    guard super.beginTracking(touch, with: event) else { return false }
    enlargeThumb()
    minimumTrackTintColor = minimumTrackTintColorForHighlighted
    return true
  }
  
  override open func endTracking(_ touch: UITouch?, with event: UIEvent?) {
    super.endTracking(touch, with: event)
    shrinkThumb()
    minimumTrackTintColor = minimumTrackTintColorForNormal
  }
  
  override open func cancelTracking(with event: UIEvent?) {
    super.cancelTracking(with: event)
    shrinkThumb()
    minimumTrackTintColor = minimumTrackTintColorForNormal
  }
}

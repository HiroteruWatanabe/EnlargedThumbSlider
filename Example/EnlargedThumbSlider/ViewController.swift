//
//  ViewController.swift
//  EnlargedThumbSlider
//
//  Created by HiroteruWatanabe on 11/23/2018.
//  Copyright (c) 2018 HiroteruWatanabe. All rights reserved.
//

import UIKit
import EnlargedThumbSlider

class ViewController: UIViewController {
  
  @IBOutlet weak var slider: EnlargedThumbSlider!
  @IBOutlet weak var playingTimeLabel: UILabel!
  @IBOutlet weak var playingTimeLabelTopConstraint: NSLayoutConstraint!
  @IBOutlet weak var remainingTimeLabel: UILabel!
  @IBOutlet weak var remainingTimeLabelTopConstraint: NSLayoutConstraint!
  
  let primaryColor = UIColor(red: 255/255.0, green: 39/255.0, blue: 75/255.0, alpha: 1.0)
  
  override func viewDidLoad() {
    super.viewDidLoad()
    slider.setMinimumTrackTintColor(.darkGray, for: .normal)
    slider.setMinimumTrackTintColor(primaryColor, for: .highlighted)
    slider.maximumTrackTintColor = .lightGray
    slider.setCircleThumb(color: .darkGray, for: .normal)
    slider.setCircleThumb(color: primaryColor, for: .highlighted)
    slider.thumbOuterColor = view.backgroundColor ?? .clear
    let playingTime = Int(slider.value)
    let remainingTime = Int(slider.maximumValue - slider.value)
    playingTimeLabel.text = String(format: "%d:%02d", playingTime / 60, playingTime % 60)
    remainingTimeLabel.text = String(format: "%d:%02d", remainingTime / 60, remainingTime % 60)
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  func updateLabelLayout(sender: UISlider) {
    var needsLayout = false
    let trackFrame = sender.convert(sender.trackRect(forBounds: sender.bounds), to: view)
    let thumbFrame = sender.thumbRect(forBounds: sender.bounds, trackRect: trackFrame, value: sender.value)
    if playingTimeLabel.frame.maxX > thumbFrame.minX {
      if playingTimeLabelTopConstraint.constant != 0 {
        playingTimeLabelTopConstraint.constant = 0
        needsLayout = true
      }
    } else {
      if playingTimeLabelTopConstraint.constant != -12 {
        playingTimeLabelTopConstraint.constant = -12
        needsLayout = true
      }
    }
    
    if remainingTimeLabel.frame.minX < thumbFrame.maxX {
      if remainingTimeLabelTopConstraint.constant != 0 {
        remainingTimeLabelTopConstraint.constant = 0
        needsLayout = true
      }
    } else {
      if remainingTimeLabelTopConstraint.constant != -12 {
        remainingTimeLabelTopConstraint.constant = -12
        needsLayout = true
      }
    }
    guard needsLayout else { return }
    UIView.animate(withDuration: 0.2) {
      self.view.layoutIfNeeded()
    }
  }
  
  @IBAction func valueChangedSlider(_ sender: UISlider) {
    updateLabelLayout(sender: sender)
    let playingTime = Int(sender.value)
    let remainingTime = Int(sender.maximumValue - sender.value)
    playingTimeLabel.text = String(format: "%d:%02d", playingTime / 60, playingTime % 60)
    remainingTimeLabel.text = String(format: "%d:%02d", remainingTime / 60, remainingTime % 60)
  }
  
  @IBAction func touchedUpSlider(_ sender: UISlider) {
    playingTimeLabelTopConstraint.constant = -12
    remainingTimeLabelTopConstraint.constant = -12
    if #available(iOS 13.0, *) {
      playingTimeLabel.textColor = .label
    } else {
      playingTimeLabel.textColor = .black
    }
    view.layoutIfNeeded()
  }
  
  @IBAction func touchedDownSlider(_ sender: UISlider) {
    updateLabelLayout(sender: sender)
    playingTimeLabel.textColor = primaryColor
  }
  
  @IBAction func touchCancelledSlider(_ sender: UISlider) {
    playingTimeLabelTopConstraint.constant = -12
    remainingTimeLabelTopConstraint.constant = -12
    if #available(iOS 13.0, *) {
      playingTimeLabel.textColor = .label
    } else {
      playingTimeLabel.textColor = .black
    }
    view.layoutIfNeeded()
  }
}


# EnlargedThumbSlider

[![CI Status](https://img.shields.io/travis/HiroteruWatanabe/EnlargedThumbSlider.svg?style=flat)](https://travis-ci.org/HiroteruWatanabe/EnlargedThumbSlider)
[![Version](https://img.shields.io/cocoapods/v/EnlargedThumbSlider.svg?style=flat)](https://cocoapods.org/pods/EnlargedThumbSlider)
[![License](https://img.shields.io/cocoapods/l/EnlargedThumbSlider.svg?style=flat)](https://cocoapods.org/pods/EnlargedThumbSlider)
[![Platform](https://img.shields.io/cocoapods/p/EnlargedThumbSlider.svg?style=flat)](https://cocoapods.org/pods/EnlargedThumbSlider)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Features

EnlargedThumbSlider imitates Apple's Music app Slider behavior.
When slider is highlighted, the slider's thumb is enlarged and changes color with animation.

### Normal state
<img src="https://user-images.githubusercontent.com/32364302/48955864-46b07300-ef93-11e8-8646-d4a8a9396ed6.PNG" width="300">

### Highlighted
<img src="https://user-images.githubusercontent.com/32364302/48955878-529c3500-ef93-11e8-964c-6404d4f30d36.PNG" width="300">

## Usage

```Swift
func setupSlider() {
// The color is supposed to be the same color as slider's backgroundColor or superview color.
slider.thumbOuterColor = .white // Set the color of the thumb outer side. 

slider.setMinimumTrackTintColor(.darkGray, for: .normal) 
slider.setMinimumTrackTintColor(primaryColor, for: .highlighted)
slider.maximumTrackTintColor = .lightGray 
slider.setCircleThumb(color: .darkGray, for: .normal) 
slider.setCircleThumb(color: primaryColor, for: .highlighted)
}
```

## Requirements

iOS 10.0 or later

## Installation

EnlargedThumbSlider is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'EnlargedThumbSlider'
```

## Author

HiroteruWatanabe, nicori.jsb@gmail.com

## License

EnlargedThumbSlider is available under the MIT license. See the LICENSE file for more info.

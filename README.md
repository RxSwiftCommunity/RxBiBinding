# RxBiBinding

[![Build Status](https://travis-ci.org/RxSwiftCommunity/RxBiBinding.svg?branch=master)](https://travis-ci.org/RxSwiftCommunity/RxBiBinding)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Version](https://img.shields.io/cocoapods/v/RxBiBinding.svg?style=flat)](https://cocoapods.org/pods/RxBiBinding)
[![License](https://img.shields.io/cocoapods/l/RxBiBinding.svg?style=flat)](https://cocoapods.org/pods/RxBiBinding)
[![Platform](https://img.shields.io/cocoapods/p/RxBiBinding.svg?style=flat)](https://cocoapods.org/pods/RxBiBinding)

## Example

Binding between two ControlProperty
```swift
let disposeBag = DisposeBag()

var textFieldFirst = UITextField()
var textFieldSecond = UITextField()

(textFieldFirst.rx.text <-> textFieldSecond.rx.text).disposed(by: disposeBag)
```

Binding between two BehaviorRelay
```swift
let disposeBag = DisposeBag()

var textFirst = BehaviorRelay<String?>(value: "")
var textSecond = BehaviorRelay<String?>(value: "")

(textFirst <-> textSecond).disposed(by: disposeBag)
```

Binding between ControlProperty and BehaviorRelay
```swift
let disposeBag = DisposeBag()

var text = BehaviorRelay<String?>(value: "")
var textField = UITextField()

(textField.rx.text <-> text).disposed(by: disposeBag)
```

## Requirements

iOS >= 10

## Installation

RxBiBinding is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'RxBiBinding'
```

Carthage
```
carthage update --platform ios
```

## Thanks

This solution is based on [ReactiveCocoa](https://github.com/ReactiveCocoa/ReactiveCocoa) (Obj-C version)

## License

RxBiBinding is available under the MIT license. See the LICENSE file for more info.
Copyright (c) RxSwiftCommunity

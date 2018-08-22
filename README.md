# RxBiBinding

[![Version](https://img.shields.io/cocoapods/v/RxBiBinding.svg?style=flat)](https://cocoapods.org/pods/RxBiBinding)
[![License](https://img.shields.io/cocoapods/l/RxBiBinding.svg?style=flat)](https://cocoapods.org/pods/RxBiBinding)
[![Platform](https://img.shields.io/cocoapods/p/RxBiBinding.svg?style=flat)](https://cocoapods.org/pods/RxBiBinding)

## Example

Binding between ControlProperty and Variable
```swift
let disposeBag = DisposeBag()

var text = Variable<String?>("")
var textField: UITextField = UITextField()

(textField.rx.text <-> text).disposed(by: disposeBag)
```

Binding between two NSObject
```swift
class TestClass: NSObject {
    @objc dynamic var string = "TestString"
}

let disposeBag = DisposeBag()
var test1 = TestClass()
var test2 = TestClass()

((test1, "string") <-> (test2, "string")).disposed(by: disposeBag)
```

## Requirements

iOS >= 10

## Installation

RxBiBinding is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'RxBiBinding'
```

## Author

Davarg, maka-dava@yandex.ru

## License

RxBiBinding is available under the MIT license. See the LICENSE file for more info.

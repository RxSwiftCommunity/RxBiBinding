#
# Be sure to run `pod lib lint RxBiBinding.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'RxBiBinding'
  s.version          = '0.2.5'
  s.summary          = 'Bidirectional binding. Inspired by ReactiveCocoa'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
Reactive bidirectional (two-way) binding between RxControlProperties and RxVariables. Of course you can use this library and for NSObject
                       DESC

  s.homepage         = 'https://github.com/RxSwiftCommunity/RxBiBinding'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Davarg' => 'maka-dava@yandex.ru' }
  s.source           = { :git => 'https://github.com/RxSwiftCommunity/RxBiBinding.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/Underbridgins'

  s.ios.deployment_target = '10.0'
  s.osx.deployment_target = '10.9'
  s.swift_version = '5.0'
  s.source_files = 'RxBiBinding/Classes/**/*'

  # s.resource_bundles = {
  #   'RxBiBinding' => ['RxBiBinding/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  s.dependency "RxSwift", "~> 5.0"
  s.dependency "RxCocoa", "~> 5.0"
end

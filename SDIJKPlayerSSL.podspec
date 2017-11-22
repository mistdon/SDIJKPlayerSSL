#
# Be sure to run `pod lib lint SDIJKPlayerSSL.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'SDIJKPlayerSSL'
  s.version          = '1.0.0'
  s.summary          = 'A Pod wrapper SDIJKPlayerSSL.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = "This is a wrapper of IJKMediaPlayerFramworkSSL"

  s.homepage         = 'https://github.com/momo13014/SDIJKPlayerSSL'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'momo13014' => 'shendong13014@gmail.com' }
  s.source           = { :git => 'https://github.com/momo13014/SDIJKPlayerSSL.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_file s = 'SDIJKPlayerSSL/Classes/**/*'
  
  # s.resource_bundles = {
  #   'SDIJKPlayerSSL' => ['SDIJKPlayerSSL/Assets/*.png']
  # }

    s.frameworks = 'AudioToolbox', 'AVFoundation', 'CoreGraphics', 'CoreMedia', 'CoreVideo', 'MediaPlayer', 'MobileCoreServices', 'OpenGLES', 'QuartzCore', 'UIKit', 'VideoToolbox'
    s.libraries = 'z', 'bz2'
    s.ios.vendored_frameworks = 'VendorFrameworks/IJKMediaFrameworkWithSSL.framework'
end

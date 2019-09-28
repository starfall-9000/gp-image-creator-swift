#
# Be sure to run `pod lib lint GPImageEditor.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'GPImageEditor'
  s.version          = '0.1.1'
  s.summary          = 'image editor for swift.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
an awesome library written by swift for editting image.
                       DESC

  s.homepage         = 'https://github.com/starfall-9000/gp-image-creator-swift'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'starfall-9000' => 'starfall.9000.21@gmail.com' }
  s.source           = { :git => 'https://github.com/starfall-9000/gp-image-creator-swift.git' }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '9.0'

  s.source_files = 'GPImageEditor/Classes/**/*'
  
   s.resource_bundles = {
       'GPImageEditor' => ['GPImageEditor/Assets/*.{png,xib,json}']
   }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
  s.dependency 'DTMvvm'
  s.dependency 'FittedSheets'
end

#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = 'gallery_saver'
  s.version          = '0.0.1'
  s.summary          = 'Saves images and videos to gallery and photos.'
  s.description      = <<-DESC
Saves images and videos to gallery and photos.
                       DESC
  s.homepage         = 'https://www.google.com'
  s.license          = { :type => 'Apache-2.0', :file => 'LICENSE' }
  s.author           = { 'Jose Mangandid' => 'mangandid35@gmail.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  s.swift_version = '5.0'

  s.ios.deployment_target = '8.0'
end


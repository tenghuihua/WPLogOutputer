#
#  Be sure to run `pod spec lint WPLogOutputer.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|


  s.name         = "WPLogOutputer"
  s.version      = "0.0.1"
  s.summary      = "离线日志打印神器"

  s.description  = <<-DESC
                    离线日志打印神器,欢迎使用.
                   DESC

  s.homepage     = "https://github.com/anrikgwp/WPLogOutputer"
  s.license      = "MIT"
  # s.license      = { :type => "MIT", :file => "FILE_LICENSE" }

  s.author             = { "Anrik_gwp" => "anrik_gwp@163.com" }
  # Or just: s.author    = "Anrik_gwp"

  s.platform     = :ios, "7.0"

  s.source       = { :git => "https://github.com/anrikgwp/WPLogOutputer.git", :tag => s.version }


  s.source_files  = "Classes" ,"WPLogOutputerDemo/WPLogOutputer/*.{h,m}"
  s.exclude_files = "Classes/Exclude"
  s.requires_arc = true
  # s.public_header_files = "Classes/**/*.h"


  # s.resource  = "icon.png"
  # s.resources = "Resources/*.png"

  # s.preserve_paths = "FilesToSave", "MoreFilesToSave"



end

#
#  Be sure to run `pod spec lint WPLogOutputer.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|
  s.name         = "WPLogOutputer"
  s.version      = "0.0.2"
  s.summary      = "离线日志打印神器"
  # s.description  = <<-DESC
                    # 离线日志打印神器,欢迎使用.
                   # DESC
  s.homepage     = "https://github.com/anrikgwp/WPLogOutputer"
  s.license      = "MIT"
  # s.license      = { :type => "MIT", :file => "FILE_LICENSE" }
  s.author             = { "Anrik_gwp" => "anrik_gwp@163.com" }
  s.platform     = :ios, "7.0"
  s.source       = { :git => "https://github.com/anrikgwp/WPLogOutputer.git", :tag => s.version }
  s.source_files  = "WPLogOutputer" ,"WPLogOutputer/*.{h,m}"
  s.requires_arc = true
end

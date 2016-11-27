platform :ios, '9.0'
use_frameworks!

target 'FUMC' do
  pod 'NSDate+TimeAgo', :inhibit_warnings => true
  pod 'SwiftMoment', '0.7'
  pod 'Locksmith', '3.0.0'
  pod 'FBSDKLoginKit', '4.16.1'
  pod 'RealmSwift', '2.1.0'
  pod 'EZSwiftExtensions'

  target 'FUMCTests' do
    inherit! :search_paths
  end
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['SWIFT_VERSION'] = '3.0'
    end
  end
end

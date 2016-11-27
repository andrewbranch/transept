platform :ios, '8.1'
use_frameworks!

target 'FUMC' do
  pod 'NSDate+TimeAgo', :inhibit_warnings => true
  pod 'SwiftMoment', :inhibit_warnings => true, :git => 'https://github.com/andrewbranch/SwiftMoment.git', :commit => 'e5882ea'
  pod 'Locksmith', '2.0.8'
  pod 'FBSDKLoginKit', '4.16.1'
  pod 'RealmSwift'

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

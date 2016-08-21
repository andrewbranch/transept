platform :ios, '8.1'
use_frameworks!

target 'FUMC' do
  pod 'NSDate+TimeAgo', :inhibit_warnings => true
  pod 'SwiftMoment', :inhibit_warnings => true, :git => 'https://github.com/andrewbranch/SwiftMoment.git', :commit => 'e5882ea'
  pod 'Locksmith', '2.0.8'
  pod 'FBSDKLoginKit'

  target 'FUMCTests' do
    inherit! :search_paths
  end

  target 'FUMCUITests' do
    inherit! :search_paths
    pod 'Nocilla'
  end
end

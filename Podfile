# Uncomment the next line to define a global platform for your project
 platform :ios, '10.0'

 source 'git@github.com:applicaster/CocoaPods.git'
 source 'git@github.com:applicaster/CocoaPods-Private.git'
 source 'https://7sports-applicaster-token:MZ3z_WMeyR6HxmZ1c9Y2@gitlab.p7s1.io/platforms-ios/CocoaPods-Specs.git'
 source 'https://cdn.cocoapods.org/'

 pre_install do |installer|
 	# workaround for https://github.com/CocoaPods/CocoaPods/issues/3289
 	Pod::Installer::Xcode::TargetValidator.send(:define_method, :verify_no_static_framework_transitive_dependencies) {}
 end

target 'EasyTrackingAnalytics' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for EasyTrackingAnalytics
 pod 'ZappPlugins'
 pod 'EasyTracking/EchoTracker'
 pod 'EasyTracking/GoogleAnalytics'
 pod 'EasyTracking/INFOnline'
 pod 'EasyTracking/Nielsen'
 pod 'EasyTracking/Mixpanel'
 pod 'OasisJSBridge', '=0.3.8'

  target 'EasyTrackingAnalyticsTests' do
    # inherit! :search_paths
    # Pods for testing
  end

end

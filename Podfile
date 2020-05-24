# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'
source 'git@github.com:applicaster/CocoaPods-Private.git'
source 'git@github.com:applicaster/CocoaPods.git'
source 'https://cdn.cocoapods.org/'

pre_install do |installer|
  # workaround for https://github.com/CocoaPods/CocoaPods/issues/3289
  Pod::Installer::Xcode::TargetValidator.send(:define_method, :verify_no_static_framework_transitive_dependencies) {}
end

target 'EasyTracking' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!
  pod 'EasyTracking' , :path => 'EasyTracking.podspec'
  # Pods for EasyTracking
end

  target 'EasyTrackingTests' do
    use_frameworks!
    inherit! :search_paths
    # Pods for testing
end

  post_install do |installer|
      installer.pods_project.targets.each do |target|
          target.build_configurations.each do |config|
              config.build_settings['SWIFT_VERSION'] = '5.1'
              config.build_settings['ENABLE_BITCODE'] = 'YES'
              config.build_settings['EXPANDED_CODE_SIGN_IDENTITY'] = ""
              config.build_settings['CODE_SIGNING_REQUIRED'] = "NO"
              config.build_settings['CODE_SIGNING_ALLOWED'] = "NO"
              config.build_settings['OTHER_CFLAGS'] = ['$(inherited)', "-fembed-bitcode"]
              config.build_settings['BITCODE_GENERATION_MODE']  = "bitcode"
          end
      end
end

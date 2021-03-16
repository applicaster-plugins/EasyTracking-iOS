Pod::Spec.new do |s|
  s.name             = "EasyTrackingAnalytics"
  s.version          = '0.6.0'
  s.summary          = "EasyTrackingAnalytics"
  s.description      = <<-DESC
                        EasyTrackingAnalytics.
                       DESC
  s.homepage         = "https://github.com/applicaster-plugins/EasyTrackingAnalytics-iOS"
  s.license          = 'CMPS'
  s.author           = "Applicaster LTD."
  s.source           = { :git => "git@github.com:applicaster-plugins/EasyTrackingAnalytics-iOS.git", :tag => s.version.to_s }
  s.platform         = :ios, '10.0'
  s.requires_arc = true
  s.static_framework = true

  s.source_files  = 'EasyTrackingAnalytics/**/*.{h,m,swift}'
  s.resources = [ 'EasyTrackingAnalytics/**/*.{xib,png}']

  s.xcconfig =  {
                  'CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES' => 'YES',
                  'ENABLE_BITCODE' => 'YES',
                  'SWIFT_VERSION' => '5.1'
                }

  s.dependency 'ZappPlugins'
  s.dependency 'EasyTracking/EchoTracker'
  s.dependency 'EasyTracking/GoogleAnalytics'
  s.dependency 'EasyTracking/INFOnline'
  s.dependency 'EasyTracking/Mixpanel'
  s.dependency 'EasyTracking/Nurago'
  s.dependency 'ZappATTPreparation'

end

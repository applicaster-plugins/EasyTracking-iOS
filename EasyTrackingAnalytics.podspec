Pod::Spec.new do |s|
  s.name             = "EasyTracking"
  s.version          = '0.1.2'
  s.summary          = "EasyTracking"
  s.description      = <<-DESC
                        EasyTracking.
                       DESC
  s.homepage         = "https://github.com/applicaster-plugins/EasyTracking-iOS"
  s.license          = 'CMPS'
  s.author           = "Applicaster LTD."
  s.source           = { :git => "git@github.com:applicaster-plugins/EasyTracking-iOS.git", :tag => s.version.to_s }
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

  s.dependency 'ApplicasterSDK'
  s.dependency 'EasyTracking'
  s.dependency 'EasyTracking/EchoTracker'


end

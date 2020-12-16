Pod::Spec.new do |s|
  s.name  = "__framework_name__"
  s.version = '__version__'
  s.platform  = :ios, '__ios_platform_version__'
  s.summary = "__framework_name__"
  s.description = "__framework_name__ container."
  s.homepage  = "https://github.com/applicaster-plugins/__framework_name__-iOS"
  s.license = 'CMPS'
	s.author = "Applicaster LTD."
	s.source = {
      "http" => "__source_url__"
  }

  s.requires_arc = true
  s.static_framework = true
  s.vendored_frameworks = '__framework_name__.framework'
  s.exclude_files = '__framework_name__/EasyTrackingAnalytics.h'
  
  s.xcconfig =  { 'CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES' => 'YES',
                  'ENABLE_BITCODE' => 'YES',
                  'SWIFT_VERSION' => '__swift_version__'
              }

  s.dependency 'ZappPlugins'
  s.dependency 'EasyTracking/EchoTracker'
  s.dependency 'EasyTracking/GoogleAnalytics'
  s.dependency 'EasyTracking/INFOnline'
  s.dependency 'EasyTracking/Nielsen'
  s.dependency 'EasyTracking/Mixpanel'
  s.dependency 'EasyTracking/Nurago'

end

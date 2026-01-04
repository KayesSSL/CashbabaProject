Pod::Spec.new do |s|
  s.name             = 'CashBabaSDK'
  s.version          = '1.0.0'
  s.summary          = 'CashBaba iOS SDK'

  s.description      = <<-DESC
                       CashBabaSDK framework for iOS
                       DESC

  s.homepage         = 'https://example.com/CashBabaSDK'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Imrul Kayes' => 'imrul@example.com' }
  s.platform         = :ios, '15.0'
  s.source           = { :path => '.' } # <-- important for local development
  s.source_files     = 'CashBabaSDK/**/*.{swift,h}' # include all source files
  s.swift_version    = '5.0'
  
  # Include resource bundles and assets
  s.resource_bundles = {
    'CBSDKResources' => [
      'CashBabaSDK/CBSDK/Assets/CBSDKResources.bundle/**/*',
      'CashBabaSDK/CBSDK/Assets/Assets.xcassets'
    ]
  }
end


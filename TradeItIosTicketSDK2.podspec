Pod::Spec.new do |s|
  s.name             = 'TradeItIosTicketSDK2'
  s.version          = '2.0.0'
  s.summary          = 'Trade It iOS Ticket SDK 2'

  s.description      = <<-DESC
  The Trade It iOS Ticket SDK to integrate live trading, portfolio and account management in to an app.
  DESC

  s.homepage         = 'https://github.com/tradingticket/TradeItIosTicketSDK2'
  s.license          = { :type => 'Apache License 2.0', :file => 'LICENSE' }
  s.author           = { 'Trading Ticket Inc.' => 'support@trade.it' }
  s.source           = { :git => 'https://github.com/tradingticket/TradeItIosTicketSDK2.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/tradeit'

  s.ios.deployment_target = '9.0'

  s.source_files = 'TradeItIosTicketSDK2/**/*.{swift,h,m}',
    'TradeItIosEmsApi/**/*.{h,m}'

  s.resource_bundles = {
    'TradeItIosTicketSDK2' => [
      'TradeItIosTicketSDK2/**/*.{storyboard,xib,png}'
    ]
  }

  s.frameworks = 'UIKit'
  s.dependency 'PromiseKit', '~> 4.0'
  s.dependency 'MBProgressHUD', '~> 1.0.0'
  s.dependency 'JSONModel', '~> 1.7.0'
  s.dependency 'BEMCheckBox', '~> 1.4.1'
end

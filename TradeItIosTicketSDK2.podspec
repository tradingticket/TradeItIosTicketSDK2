Pod::Spec.new do |s|
  s.name             = 'TradeItIosTicketSDK2'
  s.version          = '0.0.4'
  s.summary          = 'Trade It iOS Ticket SDK 2'

  s.description      = <<-DESC
  The Trade It iOS Ticket SDK to integrate live trading, portfolio and account management in to an app.
  DESC

  s.homepage         = 'https://github.com/tradingticket/TradeItIosTicketSDK2'
  s.license          = { :type => 'Apache License 2.0', :file => 'LICENSE' }
  s.author           = { 'Trading Ticket Inc.' => 'support@trade.it' }
  s.source           = { :git => 'https://github.com/tradingticket/TradeItIosTicketSDK2.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/tradingticket'

  s.ios.deployment_target = '8.0'

  s.source_files = 'TradeItIosTicketSDK2/**/*.{swift,h}', 'TradeItIosEmsApi/**/*.{h,m}'

  s.resource_bundles = {
    'TradeItIosTicketSDK2' => ['TradeItIosTicketSDK2/**/*.{storyboard,xib,png}']
  }

  s.frameworks = 'UIKit'
  s.dependency 'PromiseKit', '~> 3.4'
end

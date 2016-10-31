source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '8.0'

use_frameworks!

def testing_pods
  pod 'Quick', '~> 0.10.0'
  pod 'Nimble', '~> 5.0.0'
end

def app_pods
  pod 'PromiseKit', '~> 4.0'
  pod 'MBProgressHUD', '~> 1.0.0'
end

target 'TradeItIosTicketSDK2Tests' do
  testing_pods
  app_pods
end

target 'TradeItIosTicketSDK2' do
  app_pods
end

target 'ExampleApp' do
  app_pods
end

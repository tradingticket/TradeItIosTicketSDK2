source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '8.0'

use_frameworks!

def testing_pods
  pod 'Quick', '~> 0.10.0'
  pod 'Nimble', '~> 7.0.1'
end

def app_pods
  pod 'PromiseKit', '~> 6.0'
  pod 'MBProgressHUD', '~> 1.1.0'
  pod 'JSONModel', '~> 1.7.0'
  pod 'BEMCheckBox', '~> 1.4.1'
end

target 'TradeItIosTicketSDK2Tests' do
  testing_pods
  app_pods
end

target 'ExampleAppUITests' do
  app_pods
end

target 'TradeItIosTicketSDK2' do
  app_pods
end

target 'ExampleApp' do
  app_pods
end

target 'ExampleAppObjC' do
  app_pods
end

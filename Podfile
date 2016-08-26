source 'https://github.com/tradingticket/SpecRepo'
source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '8.0'
 
use_frameworks!

def testing_pods
    pod 'Quick', '0.9.3'
    pod 'Nimble', '4.1.0'
end

def app_pods
  pod 'TradeItIosEmsApi', :path => '~/workspace/TradeItIosEmsApi'
  pod 'PromiseKit', '3.4'
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

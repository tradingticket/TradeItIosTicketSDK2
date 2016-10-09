# TradeIt iOS Ticket SDK 

The TradeIt Ticket SDK provides screens and flows for iOS developers who want to integrate live trading in to their app. Included are trading, portfolio and account management screens as well as an interface for pulling positions data directly to display anywhere in the app.

## Beta Notice

This library is in beta. We are actively working on it and you should pull the latest changes frequently. At this point we should have a stabilized interface for you to integrate against and we will make every effort to minimize changes to that interface. Please file a Github issue for bugs.

## Installation

### Cocoapods
Follow the [Cocoapods: Getting started guide](https://guides.cocoapods.org/using/getting-started.html) and [Cocoapods: Using Cocoapods guide](https://guides.cocoapods.org/using/using-cocoapods.html) if you've never used Cocoapods before.

Inside your `Podfile` you need to add the TradeIt spec repo as a source:

```ruby
source 'https://github.com/tradingticket/SpecRepo'
```

Under your project target add our Ticket SDK pod as a dependency:

```ruby
pod 'TradeItIosTicketSdk', '~> 0.0.1'
```

This is a base example of what it should look like:

```ruby
source 'https://github.com/tradingticket/SpecRepo'

target 'YourProjectTargetName' do
  use_frameworks!
  pod 'TradeItIosTicketSdk', '~> 0.0.1'
end
```

## Example App

The SDK includes an example Swift app target. To run, switch to the `Example App` target and click run.

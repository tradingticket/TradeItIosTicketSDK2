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
pod 'TradeItIosTicketSDK2', '~> 0.0.1'
```

This is a base example of what it should look like:

```ruby
source 'https://github.com/tradingticket/SpecRepo'

target 'YourProjectTargetName' do
  use_frameworks!
  pod 'TradeItIosTicketSDK2', '~> 0.0.1'
end
```

## Configuration

### Environments

| Environment   | Enum                      |
| ------------- | ----------                |
| Sandbox       | `TradeItEmsTestEnv`       |
| Production    | `TradeItEmsProductionEnv` |

### Dummy broker account

In the Sandbox environment there is a Dummy broker available to perform tests without connecting a live broker account. All of the API interactions are stateless and return fake data. To login, select the Dummy broker and use the credentials:

```
Username: dummy
Password: dummy
```

### Live broker accounts

Be aware that our Sandbox environment points to live broker environments. Connecting a live broker account while pointing at our Sandbox will perform real trade requests to brokers.

### Keychain Access

The Ticket SDK uses the keychain to store data. Ensure the `Keychain Sharing` entitlement is enabled by going to your app target, selecting Capabilities and switching Keychain Sharing on.

## Launching the TradeIt Screens

This is the minimal effort integration using all of the workflows and screens included in the SDK. The `TradeItLauncher` is the central object for initiating flows using the TradeIt screens. 

```swift
let launcher = TradeItLauncher(apiKey: API_KEY, environment: TradeItEmsTestEnv)

// Launching the portfolio
launcher.launchPortfolio(fromViewController: self)

// Launch the trading ticket
launcher.launchTrading(fromViewController: self)

// Launch the trading ticket with pre-configured order
let order = TradeItOrder()
order.symbol = "SYMB"
order.action = .BuyToCover
launcher.launchTrading(fromViewController: self, withOrder: order)

// Launch Account Management
launcher.launchAccountManagement(fromViewController: self)
```

## Deep Integration

Deep integration refers to using the SDK to pull balances and positions data that can be used in parent app.

### Authenticating accounts

```swift
TradeItLauncher.linkedBrokerManager.authenticateAll(onSecurityQuestion: { securityQuestion, answerSecurityQuestion in
    TradeItAlert().show(securityQuestion: securityQuestion, onViewController: self, onAnswerSecurityQuestion: answerSecurityQuestion)
}, onFinished: {
    TradeItAlert().showErrorAlert(onViewController: self, title: "authenticateAll finished", message: "\(TradeItLauncher.linkedBrokerManager.linkedBrokers.count) brokers authenticated.")
})
```

### Fetching data for an account

```swift
// Account balances - given an authenticated broker account
account.getAccountOverview(onSuccess: {
    print(account.balance)
}, onFailure: { errorResult in
    print(errorResult)
})

// Account positions - given an authenticated broker account
account.getPositions(onSuccess: {
    print(account.positions.map({ position in
        return position.position
    }))
}, onFailure: { errorResult in
    print(errorResult)
})
```

## Example App

The SDK includes an example Swift app target. To run, switch to the `Example App` target and click run.

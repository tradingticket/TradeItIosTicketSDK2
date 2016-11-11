# TradeIt iOS Ticket SDK
### &#x2757; Beta Notice &#x2757;
*This library is in beta. We are actively working on it and you should pull the latest changes frequently.  Please file a Github issue for bugs.*

## Installation
### Cocoapods (preferred)
Follow the [Cocoapods: Getting started guide](https://guides.cocoapods.org/using/getting-started.html) and [Cocoapods: Using Cocoapods guide](https://guides.cocoapods.org/using/using-cocoapods.html) if you've never used Cocoapods before.

Add the TradeIt spec repo as a source and the Ticket SDK pod as a dependency of the project target:

```ruby
source 'https://github.com/tradingticket/SpecRepo'

target 'YourProjectTargetName' do
  use_frameworks!
  pod 'TradeItIosTicketSDK2', '~> 1.0.6'
end
```

### Carthage
To integrate the Trade.it SDK into your Xcode project using [Carthage](https://github.com/Carthage/Carthage), specify it in your Cartfile:
```
github "tradingticket/TradeItIosTicketSDK2" ~> 1.0.6
```

# Usage
There are two ways to use the Trade.it SDK:
- The SDK includes pre-built screens and UI workflows that minimize the effort to integrate Trade.it trading, portfolio, and account management into an app.
- The SDK also includes a set of classes that allow developers to build custom screens and UI workflows for "deep integration" with the Trade.it API trading workflow and users' portfolio data.

To use the SDK, first instantiate the `TradeItLauncher`:
```swift
let launcher = TradeItLauncher(apiKey: API_KEY, environment: TradeItEmsTestEnv)
```
It serves as the global managing object for the SDK.

## Linked Brokers
Whenever a user links their broker, the SDK will automatically save the link (in the form of the associated Trade.it OAuth token) in the secure iOS keychain. When the app is relaunched and the `TradeItLauncher` is reinstantiated, the saved brokers are loaded from the keychain.

## Launching pre-built UI
If the user has no previously linked brokers, launching any of the pre-built screens will result in the user first being prompted to link a broker.

### Launching into the portfolio screen
By default the first valid account is preselected.
```swift
launcher.launchPortfolio(fromViewController: self)
```
### Launching the portfolio with an account selected
```swift
let linkedBroker = launcher.linkedBrokerManager.linkedBrokers.first
let account = linkedBroker.accounts.first

launcher.launchPortfolio(fromViewController: self, forLinkedBrokerAccount: account)
```
### Launch the trading ticket
```swift
launcher.launchTrading(fromViewController: self)
```
### Launch the trading ticket with pre-configured order
```swift
let order = TradeItOrder()
order.symbol = "SYMB"
order.quantity = 100
order.action = .buyToCover
order.expiration = .goodForDay
launcher.launchTrading(fromViewController: self, withOrder: order)
```
### Launch Account Management
```swift
launcher.launchAccountManagement(fromViewController: self)
```
### Launch Account Linking
```swift
launcher.launchBrokerLinking(fromViewController: self, onLinked: { linkedBroker in
    print("Newly linked broker: \(linkedBroker)")
}, onFlowAborted: {
    print("User aborted linking")
})
```

## Deep Integration

Deep integration refers to using the SDK as a programmatic workflow upon which you can build your own workflow and screens or use the raw data in your app.

### Linking a user's broker login

```swift
let authInfo = TradeItAuthenticationInfo(
    id: "dummy",
    andPassword: "pass",
    andBroker: "dummy"
)

TradeItLauncher.linkedBrokerManager.linkBroker(
    authInfo: authInfo,
    onSuccess: { linkedBroker in }
    onFailure: { errorResult in
        print(errorResult)
    }
)
```

### Authenticating accounts

```swift
TradeItLauncher.linkedBrokerManager.authenticateAll(onSecurityQuestion: { securityQuestion, answerSecurityQuestion in
    // Prompt the user for an answer and then submit it to finish authenticating
    answerSecurityQuestion(/* answer from user */)
}, onFinished: {
    // Brokers that did not successfully authenticate will have the TradeItErrorResult error property set: linkedBroker.error?
    print("\(TradeItLauncher.linkedBrokerManager.linkedBrokers.map { $0.error == nil }.count) brokers authenticated.")
})
```

### Fetching portfolio and account data

```swift
// Account balances - given an authenticated broker account
linkedBrokerAccount.getAccountOverview(onSuccess: {
    print(linkedBrokerAccount.balance)
}, onFailure: { errorResult in
    print(errorResult)
})

// Account positions - given an authenticated broker account
linkedBrokerAccount.getPositions(onSuccess: { positions in
    print(positions.map({ position in
        return position.position
    }))
}, onFailure: { errorResult in
    print(errorResult)
})
```

### Trading

```swift
// Trading - given an authenticated broker account
let order = TradeItOrder()
order.linkedBrokerAccount = linkedBrokerAccount
order.symbol = "CMG"
order.action = .buy
order.type = .limit
order.expiration = .goodUntilCanceled
quantity = 100.0
limitPrice = 395.65

order.preview(onSuccess: { previewOrder, placeOrderCallback in
    // Display previewOrder contents to user for review
    // When the user confirms, call the placeOrderCallback to place the trade
    placeOrderCallback({ result in
        // Display result contents to the user
    }, { errorResult in
        // Display errorResult contents to user
    })
}, onFailure: { errorResult in
    // Display errorResult contents to user
})
```

## Example App

The SDK includes an example Swift app target. To run, switch to the `Example App` target and click run.

## Configuration

### Environments

| Environment   | Enum                      |
| ------------- | ----------                |
| Sandbox       | `TradeItEmsTestEnv`       |
| Production    | `TradeItEmsProductionEnv` |

### Dummy broker account

In the Sandbox environment there is a Dummy broker available to perform tests without connecting a live broker account. All of the API interactions are stateless and return fake data. To login, select the Dummy broker and use the credentials:

Depending on the username you choose (password will always be "pass"), you can emulate the following scenarios:

| Username           | Response                                                                                    |
| -------------      | ----------                                                                                  |
| dummy              | no errorResult                                                                              |
| dummyNotMargin     | returns error response if request is to place a sell short or buy to cover                  |
| dummyNull          | returns null values for every field that can potentially return as null                     |
| dummySecurity      | returns security question response (answer is tradingticket)                                |
| dummyMultiple      | returns a user with multiple accounts                                                       |
| dummySecurityImage | returns response with challenge image (mainly used for IB)                                  |
| dummyOptionLong    | returns response with multiple options for the security question answer (answer is option1) |

Any other credentials will fail to authenticate.

When username is dummy, dummyMultiple or dummySecurity:

| Order Size           | Returns                                                |
| -------------        | -------------                                          |
| quantity < 50        | review response with no warning messages               |
| 50 <= quantity < 100 | returns review response with warnings and ack messages |
| quantity >= 100      | returns error response                                 |

### Live broker accounts

Be aware that our Sandbox environment points to live broker environments. Connecting a live broker account while pointing at our Sandbox will perform real trade requests to brokers.

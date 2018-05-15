import UIKit

class TradeItYahooCryptoTradingUIFlow: NSObject, YahooTradingUIFlow {
    var viewControllerProvider = TradeItViewControllerProvider(storyboardName: "TradeItYahoo")
    var order = TradeItCryptoOrder()
    var onViewPortfolioTappedHandler: OnViewPortfolioTappedHandler?
}

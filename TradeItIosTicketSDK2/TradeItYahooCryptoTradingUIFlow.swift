import UIKit

class TradeItYahooCryptoTradingUIFlow: NSObject, YahooTradingUIFlow {
    typealias TradingPreviewCellFactoryType = CryptoPreviewCellFactory
    var viewControllerProvider = TradeItViewControllerProvider(storyboardName: "TradeItYahoo")
    var order = TradeItCryptoOrder()
    var onViewPortfolioTappedHandler: OnViewPortfolioTappedHandler?
}

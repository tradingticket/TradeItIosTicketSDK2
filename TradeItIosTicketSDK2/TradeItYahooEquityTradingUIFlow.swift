import UIKit

public typealias OnViewPortfolioTappedHandler = ((
    _ presentedViewController: UIViewController,
    _ linkedBrokerAccount: TradeItLinkedBrokerAccount?
) -> Void)

class TradeItYahooEquityTradingUIFlow: YahooTradingUIFlow {
    typealias TradingPreviewCellFactoryType = EquityPreviewCellFactory

    var order: TradeItOrder

    var viewControllerProvider = TradeItViewControllerProvider(storyboardName: "TradeItYahoo")
    var onViewPortfolioTappedHandler: OnViewPortfolioTappedHandler?
}

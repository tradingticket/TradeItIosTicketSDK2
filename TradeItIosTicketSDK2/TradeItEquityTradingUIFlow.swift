import UIKit

class TradeItEquityTradingUIFlow: TradeItTradingUIFlow {
    let viewControllerProvider: TradeItViewControllerProvider = TradeItViewControllerProvider()
    var order = TradeItOrder()
    var previewOrderResult: TradeItPreviewOrderResult?
}

import UIKit

class TradeItCryptoTradingUIFlow: TradeItTradingUIFlow {
    let viewControllerProvider: TradeItViewControllerProvider = TradeItViewControllerProvider()
    var order = TradeItOrder()
    var previewOrderResult: TradeItPreviewOrderResult?
}

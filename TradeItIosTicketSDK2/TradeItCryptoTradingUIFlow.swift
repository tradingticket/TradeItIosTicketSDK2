import UIKit

class TradeItCryptoTradingUIFlow: TradeItTradingUIFlow {
    var symbolSearchStoryboardId: TradeItStoryboardID = TradeItStoryboardID.symbolSearchView

    let viewControllerProvider: TradeItViewControllerProvider = TradeItViewControllerProvider()
    var order = TradeItOrder()
    var previewOrderResult: TradeItPreviewOrderResult?
}

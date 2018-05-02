import UIKit

class TradeItCryptoTradingUIFlow: TradeItTradingUIFlow {
    typealias SymbolSearchDataSource = CryptoSymbolDataSource
    var symbolSearchStoryboardId: TradeItStoryboardID = TradeItStoryboardID.symbolSearchView

    let viewControllerProvider: TradeItViewControllerProvider = TradeItViewControllerProvider()
    var order = TradeItOrder()
    var previewOrderResult: TradeItPreviewOrderResult?
}

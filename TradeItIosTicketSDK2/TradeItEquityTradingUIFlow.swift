import UIKit

class TradeItEquityTradingUIFlow: TradeItTradingUIFlow {
    typealias SymbolSearchDataSource = EquitySymbolDataSource
    
    var symbolSearchStoryboardId: TradeItStoryboardID = TradeItStoryboardID.symbolSearchView

    let viewControllerProvider: TradeItViewControllerProvider = TradeItViewControllerProvider()
    var order = TradeItOrder()
    var previewOrderResult: TradeItPreviewOrderResult?
}

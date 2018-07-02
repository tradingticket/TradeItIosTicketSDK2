class TradeItEquityTradeService: TradeService {
    typealias PreviewTradeRequest = TradeItPreviewTradeRequest
    typealias PreviewTradeResult = TradeItPreviewTradeResult
    typealias PlaceTradeResult = TradeItPlaceTradeResult
    static let previewTradeEndpoint = "order/previewStockOrEtfOrder"
    static let placeTradeEndpoint = "order/placeStockOrEtfOrder"
    var session: TradeItSession

    required init(session: TradeItSession) {
        self.session = session
    }
}

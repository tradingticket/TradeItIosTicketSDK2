class TradeItCryptoTradeService: TradeService {
    typealias PreviewTradeRequest = TradeItCryptoPreviewTradeRequest
    typealias PreviewTradeResult = TradeItCryptoPreviewTradeResult
    typealias PlaceTradeResult = TradeItPlaceTradeResult
    static let previewTradeEndpoint = "order/previewCryptoOrder"
    static let placeTradeEndpoint = "order/placeCryptoOrder"
    var session: TradeItSession

    required init(session: TradeItSession) {
        self.session = session
    }
}

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

// TODO: Move
class TradeItCryptoPreviewTradeResult: TradeItResult {
    var orderId: String?
    var orderDetails: TradeItCryptoPreviewTradeDetails?
}

class TradeItCryptoPreviewTradeDetails {
    var estimatedTotalValue: NSDecimalNumber?
    var estimatedOrderValue: NSDecimalNumber?
    var estimatedOrderCommission: NSDecimalNumber?
    var orderPriceType: String?
    var orderLimitPrice: NSDecimalNumber?
    var orderStopPrice: NSDecimalNumber?
    var orderAction: String?
    var orderPair: String?
    var orderExpiration: String?
    var orderQuantity: NSDecimalNumber?
    var orderQuantityType: String?
    var orderCommissionLabel: String?
    var warnings: [TradeItPreviewMessage]?
}

class TradeItCryptoPreviewTradeRequest: TradeItAuthenticatedRequest {
    var accountNumber: String?
    var orderAction: String?
    var orderQuantity: NSDecimalNumber?
    var orderPair: String?
    var orderPriceType: String?
    var orderLimitPrice: NSDecimalNumber?
    var orderStopPrice: NSDecimalNumber?
    var orderExpiration: String?
    var orderQuantityType: String?
}

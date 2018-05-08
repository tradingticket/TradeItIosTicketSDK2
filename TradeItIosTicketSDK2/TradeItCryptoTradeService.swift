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

class TradeItCryptoPreviewTradeDetails: JSONModel {
    var estimatedTotalValue: NSNumber?
    var estimatedOrderValue: NSNumber?
    var estimatedOrderCommission: NSNumber?
    var orderPriceType: String?
    var orderLimitPrice: NSNumber?
    var orderStopPrice: NSNumber?
    var orderAction: String?
    var orderPair: String?
    var orderExpiration: String?
    var orderQuantity: NSNumber?
    var orderQuantityType: String?
    var orderCommissionLabel: String?
    var warnings: [TradeItPreviewMessage]?

    override static func propertyIsOptional(_ propertyName: String) -> Bool {
        return [
            "orderStopPrice",
            "orderLimitPrice"
        ].contains(propertyName)
    }
}

class TradeItCryptoPreviewTradeRequest: TradeItAuthenticatedRequest {
    var accountNumber: String?
    var orderAction: String?
    var orderQuantity: NSNumber?
    var orderPair: String?
    var orderPriceType: String?
    var orderLimitPrice: NSNumber?
    var orderStopPrice: NSNumber?
    var orderExpiration: String?
    var orderQuantityType: String?
}

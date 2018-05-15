protocol TradingPreviewCellFactory {
    associatedtype PreviewOrderResultType: TradeItResult
    init(
        previewMessageDelegate delegate: PreviewMessageDelegate,
        linkedBrokerAccount: TradeItLinkedBrokerAccount,
        previewOrderResult: Self.PreviewOrderResultType
    )
    var placeOrderResult: TradeItPlaceOrderResult? { get set }
    func generateCellData() -> [PreviewCellData]
}

protocol PreviewCellFactory {
    var placeOrderResult: TradeItPlaceOrderResult? { get set }
    func generateCellData() -> [PreviewCellData]
}

class TradeItGetPositionsResult: TradeItResult {
    var currentPage: Int?
    var totalPages: Int?
    var positions: [TradeItPosition]?
    var fxPositions: [TradeItFxPosition]?
    var accountBaseCurrency: String?
}

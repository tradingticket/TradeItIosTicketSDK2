class TradeItPreviewTradeOrderDetails: Codable {
    var orderSymbol: String
    var orderAction: String
    var orderQuantity: Double
    var orderQuantityType: String
    var orderExpiration: String
    var orderPrice: String
    var orderValueLabel: String
    var orderCommissionLabel: String
    var orderMessage: String
    var lastPrice: Double?
    var bidPrice: Double?
    var askPrice: Double?
    var timestamp: String?
    var buyingPower: Double?
    var availableCash: Double?
    var longHoldings: Double?
    var shortHoldings: Double?
    var estimatedOrderValue: Double?
    var estimatedOrderCommission: Double?
    var estimatedTotalValue: Double?
    var userDisabledMargin: Bool
    var warnings: [TradeItPreviewMessage]?
    
    init() {
        self.orderSymbol = ""
        self.orderAction = ""
        self.orderQuantity = 0.0
        self.orderQuantityType = ""
        self.orderExpiration = ""
        self.orderPrice = ""
        self.orderValueLabel = ""
        self.orderCommissionLabel = ""
        self.orderMessage =  ""
        self.lastPrice = nil
        self.bidPrice = nil
        self.askPrice = nil
        self.timestamp = ""
        self.buyingPower = nil
        self.availableCash = nil
        self.longHoldings = 0.0
        self.shortHoldings = 0.0
        self.estimatedOrderValue = nil
        self.estimatedOrderCommission = nil
        self.estimatedTotalValue = nil
        self.userDisabledMargin = false
        self.warnings = []
    }
}

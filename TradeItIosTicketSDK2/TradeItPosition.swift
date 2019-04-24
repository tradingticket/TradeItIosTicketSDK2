class TradeItPosition: Codable {
    var symbol: String?
    var symbolClass: String?
    var holdingType: String?
    var costbasis: Double?
    var lastPrice: Double?
    var quantity: Double?
    var todayGainLossDollar: Double?
    var todayGainLossAbsolute: Double?
    var todayGainLossPercentage: Double?
    var totalGainLossDollar: Double?
    var totalGainLossAbsolute: Double?
    var totalGainLossPercentage: Double?
    var exchange: String?
    var currencyCode: String
    var positionDescription: String?
    
    private enum CodingKeys: String, CodingKey {
        case symbol
        case symbolClass
        case holdingType
        case costbasis
        case lastPrice
        case quantity
        case todayGainLossDollar
        case todayGainLossAbsolute
        case todayGainLossPercentage
        case totalGainLossDollar
        case totalGainLossAbsolute
        case totalGainLossPercentage
        case exchange
        case currencyCode = "currency"
        case positionDescription = "description"
    }
}

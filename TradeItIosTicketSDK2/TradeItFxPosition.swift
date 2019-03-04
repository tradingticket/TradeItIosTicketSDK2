@objc public class TradeItFxPosition: NSObject, Codable {
    var symbol: String?
    var symbolClass: String?
    var holdingType: String?
    var quantity: Double?
    var totalUnrealizedProfitAndLossBaseCurrency: Double?
    var totalValueBaseCurrency: Double?
    var totalValueUSD: Double?
    var averagePrice: Double?
    var limitPrice: Double?
    var stopPrice: Double?
}

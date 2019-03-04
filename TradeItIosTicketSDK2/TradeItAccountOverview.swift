@objc public class TradeItAccountOverview: NSObject, Codable {
    var totalValue: Double?
    var availableCash: Double?
    var buyingPower: Double?
    var buyingPowerLabel: String?
    var dayAbsoluteReturn: Double?
    var dayPercentReturn: Double?
    var totalAbsoluteReturn: Double?
    var totalPercentReturn: Double?
    var accountBaseCurrency: String?
    var marginCash: Double?
}

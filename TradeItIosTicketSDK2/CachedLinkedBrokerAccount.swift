class CachedLinkedBrokerAccount: Codable {
    var accountName = ""
    var accountNumber = ""
    var accountIndex = ""
    var accountBaseCurrency = ""
    var balanceLastUpdated: Date?
    var balance: TradeItAccountOverview?
    var fxBalance: TradeItFxAccountOverview?
    var isEnabled = false
    var userCanDisableMargin = false
}

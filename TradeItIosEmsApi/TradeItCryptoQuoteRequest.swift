class TradeItCryptoQuoteRequest: TradeItRequest, Codable {
    var token: String = ""
    var accountNumber: String = ""
    var pair: String = ""
}

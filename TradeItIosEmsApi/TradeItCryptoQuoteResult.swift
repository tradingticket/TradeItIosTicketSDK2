class TradeItCryptoQuoteResult: TradeItResult {
    var ask: Double?
    var bid: Double?
    var open: Double?
    var last: Double?
    var volume: Double?
    var dayLow: Double?
    var dayHigh: Double?
    var dateTime: String?
    
    private enum CodingKeys : String, CodingKey {
        case ask
        case bid
        case open
        case last
        case volume
        case dayLow
        case dayHigh
        case dateTime
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.ask = try container.decode(Double.self, forKey: .ask)
        self.bid = try container.decode(Double.self, forKey: .bid)
        self.open = try container.decode(Double.self, forKey: .open)
        self.last = try container.decode(Double.self, forKey: .last)
        self.volume = try container.decode(Double.self, forKey: .volume)
        self.dayLow = try container.decode(Double.self, forKey: .dayLow)
        self.dayHigh = try container.decode(Double.self, forKey: .dayHigh)
        self.dateTime = try container.decode(String.self, forKey: .dateTime)
        try super.init(from: decoder)
    }
}

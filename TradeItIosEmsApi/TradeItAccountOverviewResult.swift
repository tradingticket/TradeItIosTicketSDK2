class TradeItAccountOverviewResult: TradeItResult {
    var accountOverview: TradeItAccountOverview?
    var fxAccountOverview: TradeItFxAccountOverview?
    
    private enum CodingKeys : String, CodingKey {
        case accountOverview
        case fxAccountOverview
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.accountOverview = try container.decodeIfPresent(TradeItAccountOverview.self, forKey: .accountOverview)
        self.fxAccountOverview = try container.decodeIfPresent(TradeItFxAccountOverview.self, forKey: .fxAccountOverview)
        try super.init(from: decoder)
    }
}

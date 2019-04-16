class TradeItOAuthLoginPopupUrlForTokenUpdateResult: TradeItResult {
    var oAuthURL: String?
    var oAuthUrl: URL? {
        return oAuthURL != nil ? URL(string: oAuthURL!) : nil
    }
    
    private enum CodingKeys : String, CodingKey {
        case oAuthURL
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.oAuthURL = try container.decode(String.self, forKey: .oAuthURL)
        try super.init(from: decoder)
    }
}

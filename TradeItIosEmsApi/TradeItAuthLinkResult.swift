class TradeItAuthLinkResult: TradeItResult {
    var userId: String = ""
    var userToken: String = ""
    
    private enum CodingKeys : String, CodingKey {
        case userId
        case userToken
    }
    
    override init() {
        super.init()
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.userId = try container.decode(String.self, forKey: .userId)
        self.userToken = try container.decode(String.self, forKey: .userToken)
        try super.init(from: decoder)
    }
}

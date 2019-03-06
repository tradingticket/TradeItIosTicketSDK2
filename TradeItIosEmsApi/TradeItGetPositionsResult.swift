class TradeItGetPositionsResult: TradeItResult {
    var currentPage: Int?
    var totalPages: Int?
    var positions: [TradeItPosition]?
    var fxPositions: [TradeItFxPosition]?
    var accountBaseCurrency: String?
    
    private enum CodingKeys : String, CodingKey {
        case currentPage
        case totalPages
        case positions
        case fxPositions
        case accountBaseCurrency
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.currentPage = try container.decode(Int.self, forKey: .currentPage)
        self.totalPages = try container.decode(Int.self, forKey: .totalPages)
        var positionsArray = try container.nestedUnkeyedContainer(forKey: .positions)
        self.positions = []
        while (!positionsArray.isAtEnd) {
            let position = try positionsArray.decode(TradeItPosition.self)
            self.positions?.append(position)
        }
        var fxPositionsArray = try container.nestedUnkeyedContainer(forKey: .fxPositions)
        self.fxPositions = []
        while (!fxPositionsArray.isAtEnd) {
            let fxPosition = try fxPositionsArray.decode(TradeItFxPosition.self)
            self.fxPositions?.append(fxPosition)
        }
        self.accountBaseCurrency = try container.decode(String.self, forKey: .accountBaseCurrency)
        try super.init(from: decoder)
    }
}

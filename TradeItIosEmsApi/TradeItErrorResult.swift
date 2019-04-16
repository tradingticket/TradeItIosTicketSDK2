@objc public class TradeItErrorResult: TradeItResult {
    var systemMessage: String?
    var errorFields: [String]?
    var code: Int?
    
    private enum CodingKeys : String, CodingKey {
        case systemMessage
        case errorFields
        case code
    }
    
    override init() {
        super.init()
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.systemMessage = try container.decodeIfPresent(String.self, forKey: .systemMessage)
        if container.contains(.errorFields) {
            var errorFieldsArray = try container.nestedUnkeyedContainer(forKey: .errorFields)
            self.errorFields = []
            while (!errorFieldsArray.isAtEnd) {
                if let errorField = try errorFieldsArray.decodeIfPresent(String.self) {
                    self.errorFields?.append(errorField)
                }
            }
        }
        self.code = try container.decode(Int.self, forKey: .code)
        try super.init(from: decoder)
    }
}

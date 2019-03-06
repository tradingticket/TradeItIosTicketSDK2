@objc public class TradeItSecurityQuestionResult: TradeItResult {
    var securityQuestion: String?
    var securityQuestionOptions: [String]?
    
    private enum CodingKeys : String, CodingKey {
        case securityQuestion
        case securityQuestionOptions
    }
    
    override public init() {
        super.init()
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.securityQuestion = try container.decode(String.self, forKey: .securityQuestion)
        var securityQuestionOptionsArray = try container.nestedUnkeyedContainer(forKey: .securityQuestionOptions)
        self.securityQuestionOptions = []
        while (!securityQuestionOptionsArray.isAtEnd) {
            let securityQuestionOption = try securityQuestionOptionsArray.decode(String.self)
            self.securityQuestionOptions?.append(securityQuestionOption)
        }
        try super.init(from: decoder)
    }
}

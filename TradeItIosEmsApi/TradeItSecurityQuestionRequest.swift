class TradeItSecurityQuestionRequest: TradeItRequest, Codable {
    var token: String?
    var securityAnswer: String
    
    init(token: String?, securityAnswer: String) {
        self.token = token
        self.securityAnswer = securityAnswer
    }
}

class TradeItSecurityQuestionRequest: TradeItRequest {
    var token: String?
    var securityAnswer: String
    
    init(token: String?, securityAnswer: String) {
        self.token = token
        self.securityAnswer = securityAnswer
    }
}

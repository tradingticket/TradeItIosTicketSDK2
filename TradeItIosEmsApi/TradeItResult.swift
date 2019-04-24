class TradeItResult: Codable {
    var status: String?
    var token: String?
    var shortMessage: String?
    var longMessages: [String]?
    
    func isSuccessful() {
        return ["SUCCESS", "REVIEW_ORDER"].contains(self.status)
    }
    
    func isSecurityQuestion() {
        return self.status == "INFORMATION_NEEDED"
    }
    
    func isReviewOrder() {
        return self.status == "REVIEW_ORDER"
    }
    
    func isError() {
        return self.status == "ERROR"
    }
}

public class TradeItResult: NSObject, Codable {
    var status: String?
    var token: String?
    public var shortMessage: String?
    public var longMessages: [String]?
    
    func isSuccessful() -> Bool {
        return ["SUCCESS", "REVIEW_ORDER"].contains(self.status)
    }
    
    func isSecurityQuestion() -> Bool {
        return self.status == "INFORMATION_NEEDED"
    }
    
    func isReviewOrder() -> Bool {
        return self.status == "REVIEW_ORDER"
    }
    
    func isError() -> Bool {
        return self.status == "ERROR"
    }
}

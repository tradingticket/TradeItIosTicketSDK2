class CachedLinkedBroker: Codable {
    var accounts: [CachedLinkedBrokerAccount] = []
    var accountsLastUpdated: Date?
    var isAccountLinkDelayedError = false
    
    func toJSONString() -> String {
        let jsonEncoder = JSONEncoder()
        do {
            let jsonData = try jsonEncoder.encode(self)
            return String(data: jsonData, encoding: .utf8) ?? ""
        } catch {
            print("TradeItSDK ERROR: error encoding CachedLinkedBroker! \(self)")
            return ""
        }
        
    }
}

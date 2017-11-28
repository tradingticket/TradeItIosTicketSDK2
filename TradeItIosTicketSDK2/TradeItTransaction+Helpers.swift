extension TradeItTransaction {
    var actionEnum: Action {
        return Action(rawValue: self.action ?? "") ?? .unknown
    }
    
    var typeEnum: TransactionType {
        return TransactionType(rawValue: self.type ?? "") ?? .unknown
    }
    
    enum Action: String {
        case buy = "BUY"
        case sell = "SELL"
        case credit = "CREDIT"
        case debit = "DEBIT"
        case short = "SHORT"
        case cover = "COVER"
        case buyOpen = "BUY_OPEN"
        case buyClose = "BUY_CLOSE"
        case sellOpen = "SELL_OPEN"
        case sellClose = "SELL_CLOSE"
        case restructure = "RESTRUCTURE"
        case rebate = "REBATE"
        case unknown = "UNKNOWN"
    }
    
    enum TransactionType: String {
        case trade = "TRADE"
        case dividend = "DIVIDEND"
        case fee = "FEE"
        case interest = "INTEREST"
        case reinvestment = "REINVESTMENT"
        case transfer = "TRANSFER"
        case journaled = "JOURNALED"
        case corp_action = "CORP_ACTION"
        case conversion = "CONVERSION"
        case unknown = "UNKNOWN"
    }
    
    
}

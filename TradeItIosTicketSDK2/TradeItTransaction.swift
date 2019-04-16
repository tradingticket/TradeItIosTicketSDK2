class TradeItTransaction: Codable {
    var date: String?
    var transactionDescription: String?
    var price: Double?
    var symbol: String?
    var commission: Double?
    var amount: Double?
    var action: String?
    var type: String?
    var id: String?
    var quantity: Double?
    
    private enum CodingKeys: String, CodingKey {
        case date
        case transactionDescription = "description"
        case price
        case symbol
        case commission
        case amount
        case action
        case type
        case id
        case quantity
    }
}

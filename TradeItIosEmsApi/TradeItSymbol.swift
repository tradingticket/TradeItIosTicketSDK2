import JSONModel

@objc class TradeItSymbolLookupCompany: JSONModel {
    let symbol: String?
    let company: String?
    
    init(symbol: String, company: String) {
        self.symbol = symbol
        self.company = company
        super.init()
    }
    
    required init(data: Data!) throws {
        fatalError("init(data:) has not been implemented")
    }
    
    required init(dictionary dict: [AnyHashable : Any]!) throws {
        fatalError("init(dictionary:) has not been implemented")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

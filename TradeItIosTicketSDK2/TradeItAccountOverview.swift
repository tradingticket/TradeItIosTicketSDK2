import ObjectMapper

extension TradeItAccountOverview: Mappable {
    
    // MARK: Mappable protocol
    
    public required convenience init?(map: Map) {
        self.init()
    }
    
    public func mapping(map: Map) {
        buyingPower <- map["buyingPower"]
    }

}

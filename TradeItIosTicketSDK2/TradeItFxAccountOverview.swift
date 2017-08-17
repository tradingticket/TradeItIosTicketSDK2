import ObjectMapper

extension TradeItFxAccountOverview: Mappable {

    // MARK: Mappable protocol
        
    public required convenience init?(map: Map) {
        self.init()
    }
    
    public func mapping(map: Map) {
        buyingPowerBaseCurrency <- map["buyingPowerBaseCurrency"]
    }
}

extension TradeitEmsEnvironments : Hashable {
    
    @objc public var hashValue : Int {
        return Int(self.rawValue)
    }
    
}

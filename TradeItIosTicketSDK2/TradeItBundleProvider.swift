class TradeItBundleProvider: NSObject {
    static func provide() -> NSBundle {
        return NSBundle.init(forClass: self)
    }
}

class TradeItBundleProvider: NSObject {
    static func provide() -> Bundle {
        let framework = Bundle.init(for: self)
        let bundlePathOptional = framework.path(forResource: "TradeItIosTicketSDK2", ofType: "bundle")
        guard let bundlePath = bundlePathOptional, let bundle = Bundle.init(path: bundlePath) else { return framework }
        return bundle
    }
}

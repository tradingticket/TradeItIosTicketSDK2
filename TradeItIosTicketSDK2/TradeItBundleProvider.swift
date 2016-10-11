class TradeItBundleProvider: NSObject {
    static func provide() -> NSBundle {
        let framework = NSBundle.init(forClass: self)
        let bundlePathOptional = framework.pathForResource("TradeItIosTicketSDK2", ofType: "bundle")
        guard let bundlePath = bundlePathOptional, let bundle = NSBundle.init(path: bundlePath) else { return framework }
        return bundle
    }
}

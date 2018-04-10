@objc public class TradeItBundleProvider: NSObject {
    static public func provide() -> Bundle {
        let framework = Bundle.init(for: self)
        let bundlePathOptional = framework.path(forResource: "TradeItIosTicketSDK2", ofType: "bundle")
        guard let bundlePath = bundlePathOptional, let bundle = Bundle.init(path: bundlePath) else { return framework }
        return bundle
    }
    
    static func registerBrokerHeaderNibCells(forTableView tableView: UITableView) {
        let bundle = provide()
        tableView.register(
            UINib(nibName: "TradeItBrokerHeaderTableViewCell", bundle: bundle),
            forCellReuseIdentifier: "TRADE_IT_BROKER_HEADER"
        )
    }

    static func registerPreviewMessageNibCells(forTableView tableView: UITableView) {
        let bundle = provide()
        tableView.register(
            UINib(nibName: "TradeItPreviewMessageTableViewCell", bundle: bundle),
            forCellReuseIdentifier: "PREVIEW_MESSAGE_CELL_ID"
        )
    }

    static func registerPreviewBrandedAccountNibCells(forTableView tableView: UITableView) {
        let bundle = provide()
        tableView.register(
            UINib(nibName: "TradeItPreviewBrandedAccountNameCell", bundle: bundle),
            forCellReuseIdentifier: "PREVIEW_BRANDED_ACCOUNT_NAME_CELL_ID"
        )
    }
}

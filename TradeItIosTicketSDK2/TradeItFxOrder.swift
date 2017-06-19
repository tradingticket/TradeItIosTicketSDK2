@objc public class TradeItFxOrder: NSObject {
    public var linkedBrokerAccount: TradeItLinkedBrokerAccount?
    public var symbol: String?

    func isValid() -> Bool {
        return true // TODO
    }
}

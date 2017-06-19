@objc public class TradeItFxOrder: NSObject {
    public var linkedBrokerAccount: TradeItLinkedBrokerAccount?
    public var symbol: String?
    public var amount: NSDecimalNumber?

    func isValid() -> Bool {
        return true // TODO
    }

    func estimatedChange() -> NSNumber? {
        return NSNumber.init(integerLiteral: 10)
    }
}

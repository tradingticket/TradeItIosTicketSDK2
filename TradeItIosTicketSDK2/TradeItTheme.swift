import UIKit

@objc public class TradeItTheme: NSObject {
    public var textColor: UIColor = UIColor.darkText
    public var warningTextColor: UIColor = UIColor.tradeItSellRedColor

    public var backgroundColor: UIColor = UIColor.white

    public var tableHeaderBackgroundColor: UIColor = UIColor.groupTableViewBackground
    public var tableHeaderTextColor: UIColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)

    public var interactivePrimaryColor: UIColor = UIColor.tradeItCoolBlueColor
    public var interactiveSecondaryColor: UIColor = UIColor.white

    public var warningPrimaryColor: UIColor = UIColor.tradeItDeepRoseColor
    public var warningSecondaryColor: UIColor = UIColor.white

    override public init() {
        super.init()
    }

    static public func light() -> TradeItTheme {
        return TradeItTheme()
    }

    static public func dark() -> TradeItTheme {
        let theme = TradeItTheme()

        theme.textColor = UIColor.white
        theme.warningTextColor = UIColor.tradeItDeepRoseColor

        theme.backgroundColor = UIColor(red: 0.26, green: 0.26, blue: 0.26, alpha: 1.0)

        theme.tableHeaderBackgroundColor = UIColor(red: 0.36, green: 0.36, blue: 0.36, alpha: 1.0)
        theme.tableHeaderTextColor = UIColor(red: 0.86, green: 0.86, blue: 0.86, alpha: 1.0)

        theme.interactivePrimaryColor = UIColor(red: 1.00, green: 0.57, blue: 0.00, alpha: 1.0)
        theme.interactiveSecondaryColor = UIColor(red: 0.26, green: 0.26, blue: 0.26, alpha: 1.0)

        theme.warningPrimaryColor = UIColor.tradeItDeepRoseColor
        theme.warningSecondaryColor = UIColor.white

        return theme
    }
}

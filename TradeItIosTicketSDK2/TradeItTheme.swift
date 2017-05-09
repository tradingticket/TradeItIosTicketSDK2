import UIKit

@objc public class TradeItTheme: NSObject {
    public var textColor: UIColor = UIColor.darkText
    public var warningTextColor: UIColor = UIColor.tradeItSellRedColor

    public var backgroundColor: UIColor = UIColor.white

    public var tableHeaderTextColor: UIColor = UIColor(red: 109 / 255, green: 110 / 255, blue: 115 / 255, alpha: 1.0)
    public var tablePlainBackgroundColor: UIColor = UIColor.white
    public var tableGroupedBackgroundColor: UIColor = UIColor.groupTableViewBackground

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

        theme.tableHeaderTextColor = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1.0)
        theme.tablePlainBackgroundColor = UIColor(red: 0.26, green: 0.26, blue: 0.26, alpha: 1.0)
        theme.tableGroupedBackgroundColor = UIColor(red: 0.20, green: 0.20, blue: 0.20, alpha: 1.0)

        theme.interactivePrimaryColor = UIColor(red: 1.00, green: 0.57, blue: 0.00, alpha: 1.0)
        theme.interactiveSecondaryColor = UIColor(red: 0.26, green: 0.26, blue: 0.26, alpha: 1.0)

        theme.warningPrimaryColor = UIColor.tradeItDeepRoseColor
        theme.warningSecondaryColor = UIColor.white

        return theme
    }
}

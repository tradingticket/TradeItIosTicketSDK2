import UIKit

@objc public class TradeItTheme: NSObject {
    static public var textColor = UIColor.white
    static public var backgroundColor = UIColor(red: 0.26, green: 0.26, blue: 0.26, alpha: 1.0)
    static public var interactiveElementColor = UIColor(red:1.00, green:0.57, blue:0.00, alpha:1.0)

    static public var interactiveTextColor = backgroundColor//UIColor(red: 1.00, green: 0.76, blue: 0.03, alpha: 1.0)
    //static public var interactiveEnableedBackgroundColor = interactiveElementColor

    //static public var inputBackgroundColor = interactiveEnabledBackgroundColor
    //static public var inputBorderColor = interactiveEnabledBackgroundColor
    static public var inputPlaceholderColor = textColor
}

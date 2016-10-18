import UIKit

class TradeItPresenter {
    static let MISSING_DATA_PLACEHOLDER = "N/A"
    static let INDICATOR_UP = "▲"
    static let INDICATOR_DOWN = "▼"
    
    static func indicator(value: Double) -> String {
        if value > 0.0 {
            return TradeItPresenter.INDICATOR_UP
        } else if value < 0 {
            return TradeItPresenter.INDICATOR_DOWN
        } else {
            return ""
        }
    }
    
    static func stockChangeColor(value: Double) -> UIColor {
        if value > 0.0 {
            return UIColor.tradeItMoneyGreenColor()
        } else if value < 0 {
            return UIColor.tradeItDeepRoseColor()
        } else {
            return UIColor.lightTextColor()
        }
    }
}

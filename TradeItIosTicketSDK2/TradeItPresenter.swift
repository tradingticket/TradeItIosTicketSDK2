import UIKit

class TradeItPresenter {
    static let DEFAULT_CURRENCY_CODE = "USD"
    static let MISSING_DATA_PLACEHOLDER = "N/A"
    static let INDICATOR_UP = "▲"
    static let INDICATOR_DOWN = "▼"
    
    static func indicator(_ value: Double) -> String {
        if value > 0.0 {
            return TradeItPresenter.INDICATOR_UP
        } else if value < 0 {
            return TradeItPresenter.INDICATOR_DOWN
        } else {
            return ""
        }
    }
    
    static func stockChangeColor(_ value: Double?) -> UIColor {
        guard let value = value else { return UIColor.lightText }
        if value < 0.0 {
            return UIColor.tradeItDeepRoseColor
        } else {
            return UIColor.tradeItMoneyGreenColor
        }
    }
}

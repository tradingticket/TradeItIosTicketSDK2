@objc public protocol TradeItAdServiceProtocol {
    func configure(
        adContainer: UIView,
        rootViewController: UIViewController,
        pageType: TradeItAdPageType,
        position: TradeItAdPosition
    )
}

@objc public enum TradeItAdPageType: Int {
    case homepage
    case watchlist
    case trading
    case portfolio
    case confirmation
    case welcome
    case link
    case general

    // Woe is me - Obj-C backwards compatibility
    public static func labelFor(_ pageType: TradeItAdPageType) -> String {
        switch(pageType) {
        case .homepage: return "homepage"
        case .confirmation: return "confirmation"
        case .general: return "general"
        case .link: return "link"
        case .portfolio: return "portfolio"
        case .trading: return "trading"
        case .watchlist: return "watchlist"
        case .welcome: return "welcome"
        }
    }
}

@objc public enum TradeItAdPosition: Int {
    case top
    case bottom
    case content1
    case content2

    // Woe is me - Obj-C backwards compatibility
    public static func labelFor(_ position: TradeItAdPosition) -> String {
        switch(position) {
        case .top: return "top"
        case .bottom: return "bottom"
        case .content1: return "content1"
        case .content2: return "content2"
        }
    }
}

@objc public class NullAdService: NSObject, TradeItAdServiceProtocol {
    public func configure(adContainer: UIView, rootViewController: UIViewController, pageType: TradeItAdPageType, position: TradeItAdPosition) {
        adContainer.isHidden = true
    }
}

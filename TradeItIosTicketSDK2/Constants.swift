@objc public class TradeItNotificationConstants: NSObject {
    // MARK: Notification names
    public static let nameViewDidAppear = TradeItNotification.Name.viewDidAppear
    public static let nameAlertShown = TradeItNotification.Name.alertShown
    public static let nameDidLink = TradeItNotification.Name.didLink
    public static let nameDidUnlink = TradeItNotification.Name.didUnlink
    public static let nameButtonTapped = TradeItNotification.Name.buttonTapped

    // MARK: Notification UserInfo keys
    public static let userInfoKeyView = TradeItNotification.UserInfoKey.view.rawValue
    public static let userInfoKeyViewTitle = TradeItNotification.UserInfoKey.viewTitle.rawValue
    public static let userInfoKeyAlertTitle = TradeItNotification.UserInfoKey.alertTitle.rawValue
    public static let userInfoKeyAlertMessage = TradeItNotification.UserInfoKey.alertMessage.rawValue
    public static let userInfoKeyError = TradeItNotification.UserInfoKey.error.rawValue
    public static let userInfoKeyButton = TradeItNotification.UserInfoKey.button.rawValue
    public static let userInfoKeyButtonTitle = TradeItNotification.UserInfoKey.buttonTitle.rawValue

    // MARK: Buttons
    public static let buttonReviewOrder = TradeItNotification.Button.reviewOrder.rawValue
    public static let buttonSubmitOrder = TradeItNotification.Button.submitOrder.rawValue
    public static let buttonEditOrder = TradeItNotification.Button.editOrder.rawValue
    public static let buttonViewPortfolio = TradeItNotification.Button.viewPortfolio.rawValue
    public static let buttonLinkSucceeded = TradeItNotification.Button.linkSucceeded.rawValue
    public static let buttonLinkFailed = TradeItNotification.Button.linkFailed.rawValue
}

public struct TradeItNotification {
    public struct Name {
        public static let alertShown =  NSNotification.Name(rawValue: "alertShown")
        public static let viewDidAppear =  NSNotification.Name(rawValue: "viewDidAppear")
        public static let didLink = NSNotification.Name(rawValue: "TradeItSDKDidLink")
        public static let didUnlink = NSNotification.Name(rawValue: "TradeItSDKDidUnlink")
        public static let buttonTapped = NSNotification.Name(rawValue: "buttonTapped")
    }

    public enum UserInfoKey: String {
        case view
        case viewTitle
        case alertTitle
        case alertMessage
        case error
        case button
        case buttonTitle
    }

    public enum Button: String {
        case reviewOrder
        case submitOrder
        case editOrder
        case viewPortfolio
        case linkSucceeded
        case linkFailed
        case linkBroker
        case linkedBrokerSelected
    }
}

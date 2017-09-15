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

    // MARK: Buttons
    public static let buttonPreviewOrder = TradeItNotification.Button.previewOrder.rawValue
    public static let buttonSubmitOrder = TradeItNotification.Button.submitOrder.rawValue
    public static let buttonEditOrder = TradeItNotification.Button.editOrder.rawValue
    public static let buttonViewPortfolio = TradeItNotification.Button.viewPortfolio.rawValue
    public static let buttonLinkSucceeded = TradeItNotification.Button.linkSucceeded.rawValue
    public static let buttonLinkFailed = TradeItNotification.Button.linkFailed.rawValue

    // MARK: Views
    public static let viewBrokerOAuth = TradeItNotification.View.brokerOAuth.rawValue
    public static let viewLinkCompletion = TradeItNotification.View.linkCompletion.rawValue
    public static let viewTrading = TradeItNotification.View.trading.rawValue
    public static let viewPreview = TradeItNotification.View.preview.rawValue
    public static let viewSubmitted = TradeItNotification.View.submitted.rawValue
    public static let viewSelectActionType = TradeItNotification.View.selectActionType.rawValue
    public static let viewSelectOrderType = TradeItNotification.View.selectOrderType.rawValue
    public static let viewSelectExpirationType = TradeItNotification.View.selectExpirationType.rawValue
    public static let viewSelectAccount = TradeItNotification.View.selectAccount.rawValue
    public static let viewSelectBroker = TradeItNotification.View.selectBroker.rawValue
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
    }

    public enum Button: String {
        case previewOrder
        case submitOrder
        case editOrder
        case viewPortfolio
        case linkSucceeded
        case linkFailed
    }

    public enum View: String {
        case brokerOAuth
        case linkCompletion
        case trading
        case preview
        case submitted
        case selectActionType
        case selectOrderType
        case selectExpirationType
        case selectAccount
        case selectBroker
    }
}

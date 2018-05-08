@objc public class TradeItNotificationConstants: NSObject {
    // MARK: Notification names
    @objc public static let nameViewDidAppear = TradeItNotification.Name.viewDidAppear
    @objc public static let nameAlertShown = TradeItNotification.Name.alertShown
    @objc public static let nameDidLink = TradeItNotification.Name.didLink
    @objc public static let nameDidUnlink = TradeItNotification.Name.didUnlink
    @objc public static let nameButtonTapped = TradeItNotification.Name.buttonTapped
    @objc public static let nameDidSelectRow = TradeItNotification.Name.didSelectRow

    // MARK: Notification UserInfo keys
    @objc public static let userInfoKeyView = TradeItNotification.UserInfoKey.view.rawValue
    @objc public static let userInfoKeyViewTitle = TradeItNotification.UserInfoKey.viewTitle.rawValue
    @objc public static let userInfoKeyAlertTitle = TradeItNotification.UserInfoKey.alertTitle.rawValue
    @objc public static let userInfoKeyAlertMessage = TradeItNotification.UserInfoKey.alertMessage.rawValue
    @objc public static let userInfoKeyError = TradeItNotification.UserInfoKey.error.rawValue
    @objc public static let userInfoKeyButton = TradeItNotification.UserInfoKey.button.rawValue
    @objc public static let userInfoKeyRowType = TradeItNotification.UserInfoKey.rowType.rawValue
    @objc public static let userInfoKeyRowLabel = TradeItNotification.UserInfoKey.rowType.rawValue

    // MARK: Buttons
    @objc public static let buttonPreviewOrder = TradeItNotification.Button.previewOrder.rawValue
    @objc public static let buttonSubmitOrder = TradeItNotification.Button.submitOrder.rawValue
    @objc public static let buttonEditOrder = TradeItNotification.Button.editOrder.rawValue
    @objc public static let buttonViewPortfolio = TradeItNotification.Button.viewPortfolio.rawValue
    @objc public static let buttonLinkSucceeded = TradeItNotification.Button.linkSucceeded.rawValue
    @objc public static let buttonLinkFailed = TradeItNotification.Button.linkFailed.rawValue

    // MARK: Views
    @objc public static let viewBrokerOAuth = TradeItNotification.View.brokerOAuth.rawValue
    @objc public static let viewLinkCompletion = TradeItNotification.View.linkCompletion.rawValue
    @objc public static let viewTrading = TradeItNotification.View.trading.rawValue
    @objc public static let viewPreview = TradeItNotification.View.preview.rawValue
    @objc public static let viewSubmitted = TradeItNotification.View.submitted.rawValue
    @objc public static let viewSelectActionType = TradeItNotification.View.selectActionType.rawValue
    @objc public static let viewSelectOrderType = TradeItNotification.View.selectOrderType.rawValue
    @objc public static let viewSelectExpirationType = TradeItNotification.View.selectExpirationType.rawValue
    @objc public static let viewSelectAccount = TradeItNotification.View.selectAccount.rawValue
    @objc public static let viewSelectBroker = TradeItNotification.View.selectBroker.rawValue

    // MARK: Row Types
    @objc public static let rowTypeBroker = TradeItNotification.RowType.broker.rawValue
    @objc public static let rowTypeFeaturedBroker = TradeItNotification.RowType.featuredBroker.rawValue
}

// NOTE: If you are adding anything to TradeItNotification you must also add it to TradeItNotificationConstants which provides Obj-C helpers
@objc public struct TradeItNotification {
    @objc public struct Name {
        @objc public static let alertShown = NSNotification.Name(rawValue: "alertShown")
        @objc public static let viewDidAppear = NSNotification.Name(rawValue: "viewDidAppear")
        @objc public static let didLink = NSNotification.Name(rawValue: "TradeItSDKDidLink")
        @objc public static let didUnlink = NSNotification.Name(rawValue: "TradeItSDKDidUnlink")
        @objc public static let buttonTapped = NSNotification.Name(rawValue: "buttonTapped")
        @objc public static let didSelectRow = NSNotification.Name(rawValue: "didSelectRow")
    }

    @objc public enum UserInfoKey: String {
        case view
        case viewTitle
        case alertTitle
        case alertMessage
        case error
        case button
        case rowType
        case rowLabel
    }

    @objc public enum Button: String {
        case previewOrder
        case submitOrder
        case editOrder
        case viewPortfolio
        case viewOrderStatus
        case linkSucceeded
        case linkFailed
    }

    @objc public enum View: String {
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

    @objc public enum RowType: String {
        case broker
        case featuredBroker
    }
}

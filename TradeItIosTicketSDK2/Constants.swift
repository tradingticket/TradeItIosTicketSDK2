@objc public class TradeItNotificationConstants: NSObject {
    // MARK: Notification names
    public static let nameViewDidAppear = TradeItNotification.Name.viewDidAppear
    public static let nameAlertShown = TradeItNotification.Name.alertShown
    public static let nameDidLink = TradeItNotification.Name.didLink
    public static let nameDidUnlink = TradeItNotification.Name.didUnlink

    // MARK: Notification UserInfo keys
    public static let userInfoKeyView = TradeItNotification.UserInfoKey.view
    public static let userInfoKeyViewTitle = TradeItNotification.UserInfoKey.viewTitle
    public static let userInfoKeyAlertTitle = TradeItNotification.UserInfoKey.alertTitle
    public static let userInfoKeyAlertMessage = TradeItNotification.UserInfoKey.alertMessage
    public static let userInfoKeyError = TradeItNotification.UserInfoKey.error
}

public struct TradeItNotification {
    public struct Name {
        public static let alertShown =  NSNotification.Name(rawValue: "alertShown")
        public static let viewDidAppear =  NSNotification.Name(rawValue: "viewDidAppear")
        public static let didLink = NSNotification.Name(rawValue: "TradeItSDKDidLink")
        public static let didUnlink = NSNotification.Name(rawValue: "TradeItSDKDidUnlink")
    }

    public struct UserInfoKey {
        public static let view = "view"
        public static let viewTitle = "viewTitle"
        public static let alertTitle = "alertTitle"
        public static let alertMessage = "alertMessage"
        public static let error = "error"
    }
}

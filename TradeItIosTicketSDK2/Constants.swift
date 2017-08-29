@objc public class TradeItNotificationConstants: NSObject {
    // MARK: Notification names
    public static let nameViewDidAppear = TradeItNotification.Name.viewDidAppear
    public static let nameErrorShown = TradeItNotification.Name.errorShown
    public static let nameDidLink = TradeItNotification.Name.didLink
    public static let nameDidUnlink = TradeItNotification.Name.didUnlink

    // MARK: Notification UserInfo keys
    public static let userInfoKeyView = TradeItNotification.UserInfoKey.view
    public static let userInfoKeyErrorTitle = TradeItNotification.UserInfoKey.errorTitle
    public static let userInfoKeyErrorMessage = TradeItNotification.UserInfoKey.errorMessage
    public static let userInfoKeyError = TradeItNotification.UserInfoKey.error
}

public struct TradeItNotification {
    public struct Name {
        public static let errorShown =  NSNotification.Name(rawValue: "errorShown")
        public static let viewDidAppear =  NSNotification.Name(rawValue: "viewDidAppear")
        public static let didLink = NSNotification.Name(rawValue: "TradeItSDKDidLink")
        public static let didUnlink = NSNotification.Name(rawValue: "TradeItSDKDidUnlink")
    }

    public struct UserInfoKey {
        public static let view = "view"
        public static let viewTitle = "viewTitle"
        public static let errorTitle = "errorTitle"
        public static let errorMessage = "errorMessage"
        public static let error = "error"
    }
}

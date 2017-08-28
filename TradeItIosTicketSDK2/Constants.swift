@objc class TradeItNotificationConstants: NSObject {
    // TODO: Move existing notification center constants here

    // MARK: Notification names
    public static let nameViewDidAppear = TradeItNotification.Name.viewDidAppear
    public static let nameErrorShown = TradeItNotification.Name.errorShown

    // MARK: Notification UserInfo keys
    public static let userInfoKeyView = TradeItNotification.UserInfoKey.view
    public static let userInfoKeyErrorTitle = TradeItNotification.UserInfoKey.errorTitle
    public static let userInfoKeyErrorMessage = TradeItNotification.UserInfoKey.errorMessage
}

public struct TradeItNotification {
    // TODO: Move existing notification center constants here

    public struct Name {
        public static let errorShown =  NSNotification.Name(rawValue: "errorShown")
        public static let viewDidAppear =  NSNotification.Name(rawValue: "viewDidAppear")
    }

    public struct UserInfoKey {
        public static let view = "view"
        public static let errorTitle = "errorTitle"
        public static let errorMessage = "errorMessage"
    }
}

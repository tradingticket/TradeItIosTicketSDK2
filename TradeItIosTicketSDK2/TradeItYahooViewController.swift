import UIKit

class TradeItYahooViewController: TradeItViewController {
    override func viewDidLoad() {
        self.enableThemeOnLoad = false
        super.viewDidLoad()
        self.enableCustomNavController()
    }

    func fireViewEventNotification(view: TradeItNotification.View, title: String? = nil) {
        let title = title ?? "NO TITLE"
        NotificationCenter.default.post(
            name: TradeItNotification.Name.viewDidAppear,
            object: nil,
            userInfo: [
                TradeItNotification.UserInfoKey.view.rawValue: view.rawValue,
                TradeItNotification.UserInfoKey.viewTitle.rawValue: title
            ]
        )
    }

    func fireButtonTapEventNotification(view: TradeItNotification.View, button: TradeItNotification.Button) {
        NotificationCenter.default.post(
            name: TradeItNotification.Name.buttonTapped,
            object: nil,
            userInfo: [
                TradeItNotification.UserInfoKey.view.rawValue: view.rawValue,
                TradeItNotification.UserInfoKey.button.rawValue: button
            ]
        )
    }
}

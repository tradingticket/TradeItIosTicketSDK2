import UIKit

class TradeItYahooViewController: CloseableViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupFuji()
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

    private func setupFuji() {
        guard let yahooNavigationController = self.navigationController as? TradeItYahooNavigationController else { return }
        self.view.backgroundColor = .clear

        // Add a white background behind everything below the navigation bar.
        // The clear background above would show previous VCs when transitions are happening otherwise.
        let containerView = UIView()
        containerView.backgroundColor = .white
        containerView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(containerView)
        self.view.sendSubview(toBack: containerView)
        self.view.addConstraints([
            containerView.heightAnchor.constraint(equalToConstant: self.view.frame.height - yahooNavigationController.navigationBarHeight),
            containerView.widthAnchor.constraint(equalTo: self.view.widthAnchor),
            containerView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            containerView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
    }
}

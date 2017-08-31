import UIKit

class TradeItYahooViewController: CloseableViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .clear

        // Add a white background behind everything below the navigation bar.
        // The clear background above would show previous VCs when transitions are happening otherwise.
        let containerView = UIView()
        containerView.backgroundColor = .white
        containerView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(containerView)
        self.view.sendSubview(toBack: containerView)
        self.view.addConstraints([
            containerView.heightAnchor.constraint(equalToConstant: self.view.frame.height - TradeItYahooNavigationController.NAVIGATION_BAR_HEIGHT),
            containerView.widthAnchor.constraint(equalTo: self.view.widthAnchor),
            containerView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            containerView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.firePageEventNotification()
    }

    func firePageEventNotification(klass: AnyClass? = nil, title: String? = nil) {
        let klass: AnyClass = klass ?? self.classForCoder
        let title = title ?? self.title ?? "NO TITLE"
        NotificationCenter.default.post(
            name: TradeItNotification.Name.viewDidAppear,
            object: nil,
            userInfo: [
                TradeItNotification.UserInfoKey.view: klass,
                TradeItNotification.UserInfoKey.viewTitle: title
            ]
        )
    }

    func fireButtonTapEventNotification(button: TradeItNotification.Button, title: String?) {
        NotificationCenter.default.post(
            name: TradeItNotification.Name.buttonTapped,
            object: nil,
            userInfo: [
                TradeItNotification.UserInfoKey.view: self.classForCoder,
                TradeItNotification.UserInfoKey.button: button,
                TradeItNotification.UserInfoKey.buttonTitle: title ?? ""
            ]
        )
    }
}

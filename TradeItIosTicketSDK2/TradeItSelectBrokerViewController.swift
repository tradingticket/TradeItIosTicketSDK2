import UIKit
import MBProgressHUD

class TradeItSelectBrokerViewController: TradeItViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var brokerTable: UITableView!

    var activityView: MBProgressHUD?
    var alertManager = TradeItAlertManager()
    var brokers: [TradeItBroker] = []
    let viewControllerProvider: TradeItViewControllerProvider = TradeItViewControllerProvider()
    var oAuthCallbackUrl: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        precondition(self.oAuthCallbackUrl != nil, "TradeItSDK ERROR: TradeItSelectBrokerViewController loaded without setting oAuthCallbackUrl!")

        self.activityView = MBProgressHUD.showAdded(to: self.view, animated: true)

        self.populateBrokers()
    }
    
    //MARK: IBAction

    @IBAction func openAccountTapped(_ sender: UIButton) {
        let brokerCenterViewController = self.viewControllerProvider.provideViewController(forStoryboardId: TradeItStoryboardID.brokerCenterView) as! TTSDKBrokerCenterViewController
        self.navigationController?.pushViewController(brokerCenterViewController, animated: true)
    }
    
    @IBAction func helpLinkWasTapped(_ sender: AnyObject) {
        self.showWebView(pageTitle: "Help", url: "https://www.trade.it/faq")
    }
    
    @IBAction func privacyLinkWasTapped(_ sender: AnyObject) {
        self.showWebView(pageTitle: "Privacy", url: "https://www.trade.it/privacy")
    }
    
    @IBAction func termsLinkWasTapped(_ sender: AnyObject) {
        self.showWebView(pageTitle: "Terms", url: "https://www.trade.it/terms")
    }
    

    //MARK: private methods

    private func populateBrokers() {
        self.activityView?.label.text = "Loading Brokers"

        TradeItSDK.linkedBrokerManager.getAvailableBrokers(
            onSuccess: { availableBrokers in
                self.brokers = availableBrokers
                self.activityView?.hide(animated: true)
                self.brokerTable.reloadData()
            },
            onFailure: {
                self.alertManager.showAlert(
                    onViewController: self,
                    withTitle: "Could not fetch brokers",
                    withMessage: "Could not fetch the brokers list. Please try again later.",
                    withActionTitle: "OK"
                )

                self.activityView?.hide(animated: true)
            }
        )
    }

    private func launchOAuth(forBroker broker: TradeItBroker) {
        guard let brokerShortName = broker.brokerShortName else {
            return
        }

        self.activityView?.label.text = "Launching broker linking"
        self.activityView?.show(animated: true)

        TradeItSDK.linkedBrokerManager.getOAuthLoginPopupUrl(
            withBroker: brokerShortName,
            oAuthCallbackUrl: self.oAuthCallbackUrl!,
            onSuccess: { url in
                self.activityView?.hide(animated: true)
                UIApplication.shared.openURL(url)
                self.dismiss(animated: true)
            },
            onFailure: { errorResult in
                self.alertManager.showError(errorResult,
                                            onViewController: self)
            }
        )
    }

    private func showWebView(pageTitle: String, url: String) {
        let webViewController = self.viewControllerProvider.provideViewController(forStoryboardId: TradeItStoryboardID.webView) as! TradeItWebViewController
        webViewController.pageTitle = pageTitle
        webViewController.url = url
        self.navigationController?.pushViewController(webViewController, animated: true)
    }
    
    // MARK: UITableViewDelegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedBroker = self.brokers[indexPath.row]
        self.brokerTable.deselectRow(at: indexPath, animated: true)
        self.launchOAuth(forBroker: selectedBroker)
    }

    // MARK: UITableViewDataSource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.brokers.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let brokerCellIdentifier = "BROKER_CELL_IDENTIFIER"

        let broker = self.brokers[indexPath.row]

        let cell = tableView.dequeueReusableCell(withIdentifier: brokerCellIdentifier) ?? UITableViewCell(style: .default, reuseIdentifier: brokerCellIdentifier)
        cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 17.0)
        cell.textLabel?.text = broker.brokerLongName
        cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
        TradeItThemeConfigurator.configure(view: cell)

        return cell
    }
}

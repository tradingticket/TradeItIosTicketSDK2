import UIKit
import MBProgressHUD
import SafariServices

class TradeItYahooBrokerSelectionViewController: CloseableViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var brokerTable: UITableView!

//    internal weak var delegate: TradeItYahooSelectBrokerViewControllerDelegate?
    var activityView: MBProgressHUD?
    var alertManager = TradeItAlertManager()
    var brokers: [TradeItBroker] = []
    var oAuthCallbackUrl: URL?

    override func viewDidLoad() {
        super.viewDidLoad()

        precondition(self.oAuthCallbackUrl != nil, "TradeItSDK ERROR: TradeItYahooBrokerSelectionViewController loaded without setting oAuthCallbackUrl!")

        self.activityView = MBProgressHUD.showAdded(to: self.view, animated: true)

        self.populateBrokers()
    }

    // MARK: Private

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
                let safariViewController = SFSafariViewController(url: url)
                self.present(safariViewController, animated: true, completion: nil)
            },
            onFailure: { errorResult in
                self.alertManager.showError(errorResult,
                                            onViewController: self)
            }
        )
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
        let broker = self.brokers[indexPath.row]

        let cell = tableView.dequeueReusableCell(withIdentifier: "TRADE_IT_YAHOO_BROKER_SELECTION_CELL_ID") ?? UITableViewCell()
        cell.textLabel?.text = broker.brokerLongName

        return cell
    }

//    override func closeButtonWasTapped(_ sender: UIBarButtonItem) {
//        super.closeButtonWasTapped(sender)
//        self.delegate?.cancelWasTapped(fromSelectBrokerViewController: self)
//    }
}

//protocol TradeItYahooSelectBrokerViewControllerDelegate: class {
//    func brokerWasSelected(_ fromSelectBrokerViewController: TradeItYahooSelectBrokerViewController, broker: TradeItBroker)
//
//    func cancelWasTapped(fromSelectBrokerViewController selectBrokerViewController: TradeItSelectBrokerViewController)
//}

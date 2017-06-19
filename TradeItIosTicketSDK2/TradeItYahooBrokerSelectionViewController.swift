import UIKit
import MBProgressHUD
import SafariServices

class TradeItYahooBrokerSelectionViewController: CloseableViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var brokerTable: UITableView!

//    internal weak var delegate: TradeItYahooSelectBrokerViewControllerDelegate?
    private var activityView: MBProgressHUD?
    private let alertManager = TradeItAlertManager(linkBrokerUIFlow: TradeItYahooLinkBrokerUIFlow())
    private var brokers: [TradeItBroker] = []
    private var featuredBrokers: [TradeItBroker] = []
    internal var oAuthCallbackUrl: URL?

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
                for broker in availableBrokers {
                    broker.featuredStockBroker ? self.featuredBrokers.append(broker) : self.brokers.append(broker)
                }

                self.activityView?.hide(animated: true)
                self.brokerTable.reloadData()
            },
            onFailure: {
                self.alertManager.showAlertWithMessageOnly(
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

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if !self.featuredBrokers.isEmpty && indexPath.section == 0 {
            return 70
        }

        return 50
    }

    // MARK: UITableViewDataSource

    func numberOfSections(in tableView: UITableView) -> Int {
        var numSections = 0
        if !self.featuredBrokers.isEmpty { numSections += 1 }
        if !self.brokers.isEmpty { numSections += 1 }

        return numSections
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if !self.featuredBrokers.isEmpty {
            let header = tableView.dequeueReusableCell(withIdentifier: "TRADE_IT_YAHOO_BROKER_SELECTION_HEADER_CELL_ID") ?? UITableViewCell()

            switch section {
            case 0:
                header.textLabel?.text = "SPONSORED BROKERS"
            case 1:
                header.textLabel?.text = "MORE BROKERS"
            default:
                print("=====> TradeIt ERROR: More than 2 table sections in Broker Selection screen")
                return nil
            }

            return header
        }

        return nil
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !self.featuredBrokers.isEmpty && section == 0 {
            return self.featuredBrokers.count
        }

        return self.brokers.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var broker: TradeItBroker?

        if !self.featuredBrokers.isEmpty && indexPath.section == 0 {
            broker = self.featuredBrokers[safe: indexPath.row]

            if let broker = broker, let brokerShortName = broker.brokerShortName {
                if let brokerLogoImage = TradeItSDK.brokerLogoService.getLogo(forBroker: brokerShortName) {
                    if let cell = tableView.dequeueReusableCell(withIdentifier: "TRADE_IT_YAHOO_FEATURED_BROKER_CELL_ID") as? TradeItYahooFeaturedBrokerTableViewCell {
                        cell.brokerLogoImageView.image = brokerLogoImage
                        return cell
                    }
                } else {
                    print("TradeIt ERROR: No broker logo provided for \(brokerShortName)")
                }
            }
        } else {
            broker = self.brokers[safe: indexPath.row]
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: "TRADE_IT_YAHOO_BROKER_SELECTION_CELL_ID") ?? UITableViewCell()
        cell.textLabel?.text = broker?.brokerLongName

        return cell
    }
}

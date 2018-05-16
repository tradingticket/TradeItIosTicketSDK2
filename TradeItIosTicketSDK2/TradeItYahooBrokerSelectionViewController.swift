import UIKit
import MBProgressHUD
import SafariServices

class TradeItYahooBrokerSelectionViewController: TradeItYahooViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var brokerTable: UITableView!

    private var activityView: MBProgressHUD?
    private let alertManager = TradeItAlertManager(linkBrokerUIFlow: TradeItYahooLinkBrokerUIFlow())
    private var brokers: [TradeItBroker] = []
    private var featuredBrokers: [TradeItBroker] = []
    internal var oAuthCallbackUrl: URL?

    weak var delegate: YahooLauncherDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        precondition(self.oAuthCallbackUrl != nil, "TradeItSDK ERROR: TradeItYahooBrokerSelectionViewController loaded without setting oAuthCallbackUrl!")

        self.activityView = MBProgressHUD.showAdded(
            to: self.view,
            animated: true
        )
        self.activityView?.removeFromSuperViewOnHide = false

        self.populateBrokers()
    }


    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.fireViewEventNotification(view: .selectBroker, title: self.title)
    }

    @IBAction func learnMoreTapped(sender: UIButton) {
        delegate?.yahooLauncherDidSelectLearnMore(fromViewController: self)
    }

    // MARK: Private

    private func populateBrokers() {
        self.activityView?.label.text = "Loading Brokers"

        TradeItSDK.linkedBrokerManager.getAvailableBrokers(
            onSuccess: { availableBrokers in
                for broker in availableBrokers {
                    if broker.isFeaturedForAnyInstrument() {
                        self.featuredBrokers.append(broker)
                    }

                    self.brokers.append(broker)
                }

                self.activityView?.hide(animated: true)
                self.brokerTable.reloadData()
            },
            onFailure: { error in
                self.alertManager.showAlertWithMessageOnly(
                    onViewController: self,
                    withTitle: "Could not fetch brokers",
                    withMessage:  error.message,
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

        self.fireViewEventNotification(view: .brokerOAuth, title: "OAuth \(brokerShortName)")

        TradeItSDK.linkedBrokerManager.getOAuthLoginPopupUrl(
            withBroker: brokerShortName,
            oAuthCallbackUrl: self.oAuthCallbackUrl!,
            onSuccess: { url in
                self.activityView?.hide(animated: true)
                let safariViewController = SFSafariViewController(url: url)
                self.present(safariViewController, animated: true, completion: nil)
            },
            onFailure: { errorResult in
                self.alertManager.showError(
                    errorResult,
                    onViewController: self
                )
                self.activityView?.hide(animated: true)
            }
        )
    }

    private func getBroker(atIndexPath indexPath: IndexPath) -> TradeItBroker {
        if self.isFeaturedCell(indexPath: indexPath) {
            return self.featuredBrokers[indexPath.row]
        } else {
            return self.brokers[indexPath.row]
        }
    }

    private func isFeaturedCell(indexPath: IndexPath) -> Bool {
        return !self.featuredBrokers.isEmpty && indexPath.section == 0
    }

    // MARK: UITableViewDelegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let isFeaturedBrokerSelected = self.isFeaturedCell(indexPath: indexPath)
        let selectedBroker = self.getBroker(atIndexPath: indexPath)
        self.fireDidSelectRowEventNotification(
            view: TradeItNotification.View.selectBroker,
            title: self.title,
            label: selectedBroker.brokerShortName,
            rowType: isFeaturedBrokerSelected ? TradeItNotification.RowType.featuredBroker : TradeItNotification.RowType.broker
        )
        self.brokerTable.deselectRow(at: indexPath, animated: true)
        self.launchOAuth(forBroker: selectedBroker)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if !self.featuredBrokers.isEmpty && indexPath.section == 0 {
            return 88
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
        let header = tableView.dequeueReusableCell(withIdentifier: "TRADE_IT_YAHOO_BROKER_SELECTION_HEADER_CELL_ID") ?? UITableViewCell()
        if self.featuredBrokers.isEmpty {
            header.textLabel?.text = "AVAILABLE BROKERS"
        } else {
            switch section {
            case 0:
                header.textLabel?.text = "SPONSORED BROKERS"
            case 1:
                header.textLabel?.text = "ALL BROKERS"
            default:
                print("=====> TradeIt ERROR: More than 2 table sections in Broker Selection screen")
                return nil
            }
        }

        return header
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView.init(frame: CGRect.zero)
        view.backgroundColor = UIColor.purple
        return view
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

            if let broker = broker, let cell = tableView.dequeueReusableCell(withIdentifier: "TRADE_IT_YAHOO_FEATURED_BROKER_CELL_ID") as? TradeItSelectBrokerTableViewCell {
                cell.populate(withBroker: broker)
                return cell
            }
        } else {
            broker = self.brokers[safe: indexPath.row]
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: "TRADE_IT_YAHOO_BROKER_SELECTION_CELL_ID") ?? UITableViewCell()
        cell.textLabel?.text = broker?.brokerLongName
        cell.textLabel?.font = UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.medium)

        return cell
    }
}

import UIKit
import MBProgressHUD
import SafariServices

class TradeItSelectBrokerViewController: CloseableViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var brokerTable: UITableView!
    @IBOutlet weak var adContainer: UIView!
    @IBOutlet weak var openNewAccountButton: UIButton!

    private var activityView: MBProgressHUD?
    private var alertManager = TradeItAlertManager()
    private var brokers: [TradeItBroker] = []
    private var featuredBrokers: [TradeItBroker] = []
    private let viewControllerProvider: TradeItViewControllerProvider = TradeItViewControllerProvider()

    public var oAuthCallbackUrl: URL?
    public var showOpenAccountButton: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

        precondition(
            self.oAuthCallbackUrl != nil,
            "TradeItSDK ERROR: TradeItSelectBrokerViewController loaded without setting oAuthCallbackUrl!"
        )

        TradeItThemeConfigurator.configure(view: self.view, groupedStyle: false)

        self.activityView = MBProgressHUD.showAdded(
            to: self.view,
            animated: true
        )
        self.activityView?.removeFromSuperViewOnHide = false

        self.populateBrokers()

        TradeItSDK.adService.populate?(
            adContainer: adContainer,
            rootViewController: self,
            pageType: .brokerList,
            position: .bottom,
            broker: nil,
            symbol: nil,
            instrumentType: nil,
            trackPageViewAsPageType: true
        )
        
        if !showOpenAccountButton {
            self.openNewAccountButton.removeFromSuperview()
        }
    }
    
    // MARK: IBAction

    @IBAction func openAccountTapped(_ sender: UIButton) {
        self.showWebView(pageTitle: "Broker Center", url: TradeItSDK.brokerCenterService.getUrl())
    }
    
    @IBAction func helpLinkWasTapped(_ sender: AnyObject) {
        self.showWebView(pageTitle: "Help", url: "https://www.trade.it/helpcenter")
    }
    
    @IBAction func privacyLinkWasTapped(_ sender: AnyObject) {
        self.showWebView(pageTitle: "Privacy", url: "https://www.trade.it/privacy-policy")
    }
    
    @IBAction func termsLinkWasTapped(_ sender: AnyObject) {
        self.showWebView(pageTitle: "Terms", url: "https://www.trade.it/terms-of-service")
    }

    // MARK: private methods

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
                    withMessage: error.message,
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
                self.present(
                    safariViewController,
                    animated: true,
                    completion: nil
                )
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

    private func showWebView(pageTitle: String, url: String) {
        let webViewController = self.viewControllerProvider.provideViewController(forStoryboardId: TradeItStoryboardID.webView) as! TradeItWebViewController
        webViewController.pageTitle = pageTitle
        webViewController.url = url
        self.navigationController?.pushViewController(webViewController, animated: true)
    }

    private func getBroker(atIndexPath indexPath: IndexPath) -> TradeItBroker {
        if !self.featuredBrokers.isEmpty && indexPath.section == 0 {
            return self.featuredBrokers[indexPath.row]
        } else {
            return self.brokers[indexPath.row]
        }
    }

    // MARK: UITableViewDelegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedBroker = self.getBroker(atIndexPath: indexPath)
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

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableCell(withIdentifier: "TRADE_IT_BROKER_SELECTION_HEADER_CELL_ID") ?? UITableViewCell()
        if self.featuredBrokers.isEmpty {
            header.textLabel?.text = "AVAILABLE BROKERS"
        } else {
            switch section {
            case 0:
                header.textLabel?.text = TradeItSDK.featuredBrokerLabelText
            case 1:
                header.textLabel?.text = "MORE BROKERS"
            default:
                print("=====> TradeIt ERROR: More than 2 table sections in Broker Selection screen")
                return nil
            }
        }

        TradeItThemeConfigurator.configureTableHeader(header: header, groupedStyle: false)
        return header
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
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

            if let broker = broker, let cell = tableView.dequeueReusableCell(withIdentifier: "TRADE_IT_FEATURED_BROKER_CELL_ID") as? TradeItFeaturedBrokerTableViewCell {
                cell.populate(withBroker: broker)
                return cell
            }
        } else {
            broker = self.brokers[safe: indexPath.row]
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: "TRADE_IT_BROKER_SELECTION_CELL_ID") ?? UITableViewCell()
        cell.textLabel?.text = broker?.brokerLongName
        cell.textLabel?.font = UIFont.systemFont(ofSize: 15, weight: UIFontWeightMedium)
        TradeItThemeConfigurator.configure(view: cell)

        return cell
    }
}

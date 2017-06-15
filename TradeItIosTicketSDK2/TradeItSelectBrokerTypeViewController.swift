import UIKit
import MBProgressHUD

enum BrokerTypes {
    case STOCK
    case FX
}

class TradeItSelectBrokerTypeViewController: TradeItViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var brokerTypeTable: UITableView!

    var alertManager = TradeItAlertManager()
    var brokers: [TradeItBroker] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // TODO ADD MBLoading
//        self.populateBrokers()

//        TradeItSDK.adService.populate(adContainer: adContainer, rootViewController: self, pageType: .link, position: .bottom)
    }

    //MARK: IBAction

    //MARK: private methods

    private func populateBrokers() {
//        self.activityView?.label.text = "Loading Brokers"

        TradeItSDK.linkedBrokerManager.getAvailableBrokers(
            onSuccess: { availableBrokers in
                self.brokers = availableBrokers
//                let brokerTypes = self.brokers.flatMap({ broker ->
//                    
//                })
//                self.activityView?.hide(animated: true)
//                self.brokerTable.reloadData()
            },
            onFailure: {
                self.alertManager.showAlertWithMessageOnly(
                    onViewController: self,
                    withTitle: "Could not fetch brokers",
                    withMessage: "Could not fetch the brokers list. Please try again later.",
                    withActionTitle: "OK"
                )

//                self.activityView?.hide(animated: true)
        }
        )
    }

    // MARK: UITableViewDelegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let selectedBroker = self.brokers[indexPath.row]
//        self.brokerTable.deselectRow(at: indexPath, animated: true)
//        self.launchOAuth(forBroker: selectedBroker)
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

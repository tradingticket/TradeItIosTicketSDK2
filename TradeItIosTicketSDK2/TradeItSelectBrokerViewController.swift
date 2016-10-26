import UIKit
import MBProgressHUD

class TradeItSelectBrokerViewController: TradeItViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var brokerTable: UITableView!
    var delegate: TradeItSelectBrokerViewControllerDelegate?
    var alertManager = TradeItAlertManager()
    var linkedBrokerManager: TradeItLinkedBrokerManager = TradeItLauncher.linkedBrokerManager
    var brokers: [TradeItBroker] = []
    let toLoginScreenSegueId = "TO_LOGIN_SCREEN_SEGUE"
    var selectedBroker: TradeItBroker?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.selectedBroker = nil

        let activityView = MBProgressHUD.showAdded(to: self.view, animated: true)
        activityView.label.text = "Loading Brokers"

        self.linkedBrokerManager.getAvailableBrokers(
            onSuccess: { availableBrokers in
                self.brokers = availableBrokers
                activityView.hide(animated: true)
                self.brokerTable.reloadData()
            },
            onFailure: { () -> Void in
                self.alertManager.showAlert(
                    onViewController: self,
                    withTitle: "Could not fetch brokers",
                    withMessage: "Could not fetch the brokers list. Please try again later.",
                    withActionTitle: "OK"
                )
                activityView.hide(animated: true)
            }
        )
    }

    // MARK: UITableViewDelegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedBroker = self.brokers[(indexPath as NSIndexPath).row]
        self.brokerTable.deselectRow(at: indexPath, animated: true)
        self.delegate?.brokerWasSelected(self, broker: self.selectedBroker!)
    }

    // MARK: UITableViewDataSource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.brokers.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let brokerCellIdentifier = "BROKER_CELL_IDENTIFIER"

        var cell = tableView.dequeueReusableCell(withIdentifier: brokerCellIdentifier)

        if cell == nil {
            cell = UITableViewCell.init(style: UITableViewCellStyle.default, reuseIdentifier: brokerCellIdentifier)
            cell?.textLabel?.font = UIFont.systemFont(ofSize: 13.0)
            cell?.textLabel?.textColor = UIColor.darkText
        }

        if let brokerLongName = self.brokers[(indexPath as NSIndexPath).row].brokerLongName {
            cell?.textLabel?.text = brokerLongName
        }
        
        return cell!
    }
}

protocol TradeItSelectBrokerViewControllerDelegate {
    func brokerWasSelected(_ fromSelectBrokerViewController: TradeItSelectBrokerViewController, broker: TradeItBroker)

    func cancelWasTapped(fromSelectBrokerViewController selectBrokerViewController: TradeItSelectBrokerViewController)
}

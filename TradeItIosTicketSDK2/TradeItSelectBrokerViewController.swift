import UIKit

class TradeItSelectBrokerViewController: TradeItViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var brokerTable: UITableView!
    var delegate: TradeItSelectBrokerViewControllerDelegate?
    var alertManager = TradeItAlertManager()
    var linkedBrokerManager: TradeItLinkedBrokerManager = TradeItLauncher.linkedBrokerManager
    var brokers: [TradeItBroker] = []
    let toLoginScreenSegueId = "TO_LOGIN_SCREEN_SEGUE"
    var ezLoadingActivityManager: EZLoadingActivityManager = EZLoadingActivityManager()
    var selectedBroker: TradeItBroker?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.selectedBroker = nil

        ezLoadingActivityManager.show(text: "Loading Brokers", disableUI: true)

        self.linkedBrokerManager.getAvailableBrokers(
            onSuccess: { (availableBrokers: [TradeItBroker]) -> Void in
                self.brokers = availableBrokers
                self.ezLoadingActivityManager.hide()
                self.brokerTable.reloadData()
            },
            onFailure: { () -> Void in
                self.alertManager.showOn(viewController: self,
                                         withAlertTitle: "Could not fetch brokers",
                                         withAlertMessage: "Could not fetch the brokers list. Please try again later.",
                                         withAlertActionTitle: "OK")
                self.ezLoadingActivityManager.hide()
            }
        )
    }

    // MARK: UITableViewDelegate

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.selectedBroker = self.brokers[indexPath.row]
        self.brokerTable.deselectRowAtIndexPath(indexPath, animated: true)
        self.delegate?.brokerWasSelected(self, broker: self.selectedBroker!)
    }

    // MARK: UITableViewDataSource

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.brokers.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let brokerCellIdentifier = "BROKER_CELL_IDENTIFIER"

        var cell = tableView.dequeueReusableCellWithIdentifier(brokerCellIdentifier)

        if cell == nil {
            cell = UITableViewCell.init(style: UITableViewCellStyle.Default, reuseIdentifier: brokerCellIdentifier)
            cell?.textLabel?.font = UIFont.systemFontOfSize(13.0)
            cell?.textLabel?.textColor = UIColor.darkTextColor()
        }

        if let brokerLongName = self.brokers[indexPath.row].brokerLongName {
            cell?.textLabel?.text = brokerLongName
        }
        
        return cell!
    }
}

protocol TradeItSelectBrokerViewControllerDelegate {
    func brokerWasSelected(fromSelectBrokerViewController: TradeItSelectBrokerViewController, broker: TradeItBroker)

    func cancelWasTapped(fromSelectBrokerViewController selectBrokerViewController: TradeItSelectBrokerViewController)
}

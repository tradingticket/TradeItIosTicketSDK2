import UIKit
import TradeItIosEmsApi

class TradeItSelectBrokerViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var brokerTable: UITableView!
    var delegate: TradeItSelectBrokerViewControllerDelegate?

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
                let alert = UIAlertController(title: "Could not fetch brokers",
                    message: "Could not fetch the brokers list. Please try again later.",
                    preferredStyle: UIAlertControllerStyle.Alert)

                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
                self.ezLoadingActivityManager.hide()
            }
        )
    }

    // MARK: UITableViewDelegate

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let broker = self.brokers[indexPath.row]
        self.selectedBroker = broker
        self.brokerTable.deselectRowAtIndexPath(indexPath, animated: true)
        delegate?.brokerWasSelected(self, broker: broker)
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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == toLoginScreenSegueId {
            if let destinationViewController = segue.destinationViewController as? TradeItLoginViewController,
                broker = self.selectedBroker {
                destinationViewController.selectedBroker = broker
            }
        }
    }
}

protocol TradeItSelectBrokerViewControllerDelegate {
    func brokerWasSelected(fromSelectBrokerViewController: TradeItSelectBrokerViewController, broker: TradeItBroker)
    // TODO: call delegate.flowAborted when users taps close/cancel
    func cancelWasTapped(fromSelectBrokerViewController selectBrokerViewController: TradeItSelectBrokerViewController)
}

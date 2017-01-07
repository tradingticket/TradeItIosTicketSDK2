import UIKit

@objc public class TradeItYahooBrokerLinkedViewController: UIViewController {
    @IBOutlet weak var brokerLabel: UILabel!
    var linkedBroker: TradeItLinkedBroker?

    public override func viewDidLoad() {
        super.viewDidLoad()

        if let linkedBroker = self.linkedBroker {
            self.brokerLabel.text = linkedBroker.brokerName
        } else {
            print("=====> ERROR: Account Linked confirmation screen loaded without setting linkedBroker")
            self.brokerLabel.text = "NO BROKER"
        }
    }

    // MARK: IBActions

    @IBAction func viewPortfolioButtonTapped(_ sender: UIButton) {
        print("=====> VIEW PORTFOLIO TAPPED!!!!!!")
    }
}

import UIKit

@objc class TradeItYahooBrokerLinkedViewController: CloseableViewController {
    @IBOutlet weak var brokerLabel: UILabel!
    var linkedBroker: TradeItLinkedBroker?
    var delegate: TradeItYahooBrokerLinkedViewControllerDelegate?

    public override func viewDidLoad() {
        super.viewDidLoad()

        if let linkedBroker = self.linkedBroker {
            self.brokerLabel.text = linkedBroker.brokerName
        } else {
            print("TradeItSDK ERROR: Account Linked confirmation screen loaded without setting linkedBroker!")
            self.brokerLabel.text = "NO BROKER"
        }
    }

    // MARK: IBActions

    @IBAction func viewPortfolioButtonTapped(_ sender: UIButton) {
        delegate?.viewPortfolioButtonTapped(fromViewController: self)

    }
}

@objc protocol TradeItYahooBrokerLinkedViewControllerDelegate {
    func viewPortfolioButtonTapped(fromViewController viewController: TradeItYahooBrokerLinkedViewController)
}

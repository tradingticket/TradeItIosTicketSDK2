import UIKit

class TradeItWelcomeViewController: UIViewController {
    var delegate: TradeItWelcomeViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: IBActions

    @IBAction func getStartedButtonWasTapped(sender: UIButton) {
        self.delegate?.getStartedButtonWasTapped(self)
    }

    @IBAction func cancelWasTapped(sender: UIBarButtonItem) {
        self.delegate?.cancelWasTapped(fromWelcomeViewController: self)
    }
}

protocol TradeItWelcomeViewControllerDelegate {
    func getStartedButtonWasTapped(fromViewController: TradeItWelcomeViewController)
    func cancelWasTapped(fromWelcomeViewController welcomeViewController: TradeItWelcomeViewController)
}

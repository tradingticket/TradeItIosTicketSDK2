import UIKit

class TradeItWelcomeViewController: UIViewController {
    var delegate: TradeItWelcomeViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationItem()
    }

    // MARK: IBActions

    @IBAction func getStartedButtonWasTapped(sender: UIButton) {
        self.delegate?.getStartedButtonWasTapped(self)
    }

    override func closeButtonWasTapped(sender: UIBarButtonItem) {
        self.delegate?.cancelWasTapped(fromWelcomeViewController: self)
    }
}

protocol TradeItWelcomeViewControllerDelegate {
    func getStartedButtonWasTapped(fromViewController: TradeItWelcomeViewController)
    func cancelWasTapped(fromWelcomeViewController welcomeViewController: TradeItWelcomeViewController)
}

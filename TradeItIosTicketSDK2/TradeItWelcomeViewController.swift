import UIKit

class TradeItWelcomeViewController: TradeItViewController {
    var delegate: TradeItWelcomeViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: IBActions

    @IBAction func getStartedButtonWasTapped(_ sender: UIButton) {
        self.delegate?.getStartedButtonWasTapped(self)
    }

    override func closeButtonWasTapped(_ sender: UIBarButtonItem) {
        self.delegate?.cancelWasTapped(fromWelcomeViewController: self)
    }
}

protocol TradeItWelcomeViewControllerDelegate {
    func getStartedButtonWasTapped(_ fromViewController: TradeItWelcomeViewController)
    func cancelWasTapped(fromWelcomeViewController welcomeViewController: TradeItWelcomeViewController)
}

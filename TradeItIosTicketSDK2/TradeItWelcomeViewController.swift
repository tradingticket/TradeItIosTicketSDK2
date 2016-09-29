import UIKit

class TradeItWelcomeViewController: UIViewController {
    var delegate: TradeItWelcomeViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: IBActions


    @IBAction func getStartedButtonWasTapped(sender: UIButton) {
        delegate?.getStartedButtonWasTapped(self)
    }
}

protocol TradeItWelcomeViewControllerDelegate {
    func getStartedButtonWasTapped(fromViewController: TradeItWelcomeViewController)
    // TODO: call delegate.flowAborted when users taps close/cancel
    func cancelWasTapped(fromWelcomeViewController welcomeViewController: TradeItWelcomeViewController)
}

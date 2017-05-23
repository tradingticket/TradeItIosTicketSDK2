import UIKit

class TradeItWelcomeViewController: TradeItViewController {
    internal weak var delegate: TradeItWelcomeViewControllerDelegate?
    @IBOutlet var bullets: [UIView]!
    @IBOutlet weak var adContainer: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        TradeItSDK.adService?.configure(adContainer: adContainer, rootViewController: self, pageType: .welcome, position: .bottom)
        for bullet in bullets {
            bullet.backgroundColor = TradeItSDK.theme.interactivePrimaryColor
        }
    }

    // MARK: IBActions

    @IBAction func getStartedButtonWasTapped(_ sender: UIButton) {
        self.delegate?.getStartedButtonWasTapped(self)
    }
}

protocol TradeItWelcomeViewControllerDelegate: class {
    func getStartedButtonWasTapped(_ fromViewController: TradeItWelcomeViewController)
}

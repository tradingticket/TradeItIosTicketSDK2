import UIKit
import MBProgressHUD
import SafariServices

class TradeItWelcomeViewController: TradeItViewController, UIGestureRecognizerDelegate {
    @IBOutlet var bullets: [UIView]!
    @IBOutlet weak var adContainer: UIView!
    @IBOutlet var bulletListView: UIView!
    @IBOutlet weak var headlineTextLabel: UILabel!
    @IBOutlet weak var featuredBrokerContainerView: UIView!
    @IBOutlet weak var featuredBrokerImageView: UIImageView!
    @IBOutlet weak var getStartedButton: UIButton!
    @IBOutlet weak var spinnerView: UIActivityIndicatorView!
    @IBOutlet weak var featuredBrokerLabel: UILabel!
    @IBOutlet weak var featuredBrokerFallbackLabel: UILabel!
    @IBOutlet weak var promotionButton: UIButton!
    @IBOutlet weak var moreBrokersButton: UIButton!

    internal weak var delegate: TradeItWelcomeViewControllerDelegate?
    private let alertManager = TradeItAlertManager()
    private var brokers: [TradeItBroker] = []
    private var activityView: MBProgressHUD?
    private var featuredBroker: TradeItBroker?

    public var headlineText = TradeItSDK.welcomeScreenHeadlineText
    public var oAuthCallbackUrl: URL?
    public var promotionText: String?
    public var promotionUrl: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        precondition(
            self.oAuthCallbackUrl != nil,
            "TradeItSDK ERROR: TradeItWelcomeViewController loaded without setting oAuthCallbackUrl!"
        )

        self.activityView = MBProgressHUD.showAdded(
            to: self.view,
            animated: true
        )

        self.headlineTextLabel.text = self.headlineText
        self.addBorder(toView: self.featuredBrokerContainerView)
        self.hideFeaturedBroker()
        self.populateBrokers()

        TradeItSDK.adService.populate(
            adContainer: adContainer,
            rootViewController: self,
            pageType: .welcome,
            position: .bottom,
            broker: nil,
            symbol: nil,
            instrumentType: nil,
            trackPageViewAsPageType: true
        )

        for bullet in bullets {
            bullet.backgroundColor = TradeItSDK.theme.interactivePrimaryColor
        }

        let gestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(handleTap(gestureRecognizer:))
        )

        gestureRecognizer.delegate = self
        self.featuredBrokerContainerView.addGestureRecognizer(gestureRecognizer)

        self.spinnerView.startAnimating()
        self.spinnerView.isHidden = false
        self.featuredBrokerFallbackLabel.isHidden = true
        self.featuredBrokerImageView.isHidden = true
    }

    // MARK: UIGestureRecognizerDelegate

    func handleTap(gestureRecognizer: UIGestureRecognizer) {
        launchFeaturedBroker()
    }

    // MARK: IBActions

    @IBAction func getStartedButtonWasTapped(_ sender: UIButton) {
        if hasFeaturedBroker() {
            launchFeaturedBroker()
        } else {
            launchBrokerSelection()
        }
    }

    @IBAction func moreBrokersButtonWasTapped(_ sender: UIButton) {
        launchBrokerSelection()
    }

    // MARK: private methods

    private func hasFeaturedBroker() -> Bool {
        return featuredBroker != nil
    }

    private func launchBrokerSelection() {
        self.delegate?.moreBrokersButtonWasTapped(self)
    }

    private func launchFeaturedBroker() {
        if let featuredBroker = featuredBroker {
            self.launchOAuth(forBroker: featuredBroker)
        }
    }

    private func launchOAuth(forBroker broker: TradeItBroker) {
        guard let brokerShortName = broker.brokerShortName else { return }

        self.activityView?.label.text = "Launching broker linking"
        self.activityView?.show(animated: true)

        TradeItSDK.linkedBrokerManager.getOAuthLoginPopupUrl(
            withBroker: brokerShortName,
            oAuthCallbackUrl: self.oAuthCallbackUrl!,
            onSuccess: { url in
                self.activityView?.hide(animated: true)
                let safariViewController = SFSafariViewController(url: url)
                self.present(
                    safariViewController,
                    animated: true,
                    completion: nil
                )
            },
            onFailure: { errorResult in
                self.alertManager.showError(
                    errorResult,
                    onViewController: self
                )
                self.activityView?.hide(animated: true)
            }
        )
    }

    private func setFeaturedBroker(featuredBroker: TradeItBroker) {
        self.featuredBroker = featuredBroker
        self.featuredBrokerFallbackLabel.text = featuredBroker.brokerLongName

        TradeItSDK.brokerLogoService.loadLogo(
            forBroker: featuredBroker,
            withSize: .large,
            onSuccess: { image in
                self.featuredBrokerImageView.image = image

                self.spinnerView.isHidden = true
                self.featuredBrokerFallbackLabel.isHidden = true
                self.featuredBrokerImageView.isHidden = false
            }, onFailure: {
                self.spinnerView.isHidden = true
                self.featuredBrokerFallbackLabel.isHidden = false
                self.featuredBrokerImageView.isHidden = true
            }
        )

        self.featuredBrokerLabel.text = TradeItSDK.featuredBrokerLabelText

        self.featuredBrokerContainerView.isHidden = false
        self.featuredBrokerLabel.isHidden = false
        self.bulletListView.isHidden = true

        self.configureMoreBrokersButton()
    }

    private func hideFeaturedBroker() {
        self.bulletListView.isHidden = false
        self.featuredBrokerContainerView.isHidden = true
        self.featuredBrokerLabel.isHidden = true
    }

    private func addBorder(toView view: UIView) {
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.tradeItlightGreyBorderColor.cgColor
        view.layer.cornerRadius = 3

        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 1)
        view.layer.shadowOpacity = 0.1
        view.layer.shadowRadius = 1
    }

    private func populateBrokers() {
        self.activityView?.label.text = "Loading Brokers"
        configurePromotionButton()
        configureMoreBrokersButton()

        TradeItSDK.linkedBrokerManager.getAvailableBrokers(
            onSuccess: { availableBrokers in
                self.brokers = availableBrokers
                self.activityView?.hide(animated: true)

                if let broker = (self.brokers.first { $0.isFeaturedForAnyInstrument() }) {
                    self.setFeaturedBroker(featuredBroker: broker)
                }

                self.configurePromotionButton()
            },
            onFailure: { _ in
                self.activityView?.hide(animated: true)
            }
        )
    }

    private func configurePromotionButton() {
        if let promotionText = self.promotionText,
            let promotionUrl = self.promotionUrl {
            self.promotionButton.setTitle(promotionText, for: .normal)
            self.promotionButton.isEnabled = true
            self.promotionButton.isHidden = false
        } else {
            self.promotionButton.isEnabled = false
            self.promotionButton.isHidden = true
        }
    }

    private func configureMoreBrokersButton() {
        if hasFeaturedBroker() {
            self.moreBrokersButton.isHidden = false
        } else {
            self.moreBrokersButton.isHidden = true
        }
    }
}

protocol TradeItWelcomeViewControllerDelegate: class {
    func moreBrokersButtonWasTapped(_ fromViewController: TradeItWelcomeViewController)
}

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

    internal weak var delegate: TradeItWelcomeViewControllerDelegate?
    private let alertManager = TradeItAlertManager()
    private var brokers: [TradeItBroker] = []
    private var activityView: MBProgressHUD?
    private var featuredBroker: TradeItBroker?

    public var headlineText = TradeItSDK.welcomeScreenHeadlineText
    public var oAuthCallbackUrl: URL?

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

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.fireViewEventNotification(view: .welcome, title: self.title)
    }

    // MARK: UIGestureRecognizerDelegate

    func handleTap(gestureRecognizer: UIGestureRecognizer) {
        if let featuredBroker = featuredBroker {
            self.fireLabelTappedEventNotification(
                view: TradeItNotification.View.welcome,
                title: self.title,
                labelText: featuredBroker.brokerShortName,
                label: TradeItNotification.Label.featuredBroker
            )
            self.launchOAuth(forBroker: featuredBroker)
        }
    }

    // MARK: IBActions

    @IBAction func getStartedButtonWasTapped(_ sender: UIButton) {
        self.delegate?.getStartedButtonWasTapped(self)
    }

    // MARK: private methods

    private func launchOAuth(forBroker broker: TradeItBroker) {
        guard let brokerShortName = broker.brokerShortName else { return }

        self.activityView?.label.text = "Launching broker linking"
        self.activityView?.show(animated: true)

        self.fireViewEventNotification(view: .brokerOAuth, title: "OAuth \(brokerShortName)")

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

        TradeItSDK.linkedBrokerManager.getAvailableBrokers(
            onSuccess: { availableBrokers in
                self.brokers = availableBrokers
                self.activityView?.hide(animated: true)

                if let broker = (self.brokers.first { $0.isFeaturedForAnyInstrument() }) {
                    self.setFeaturedBroker(featuredBroker: broker)
                    self.getStartedButton.setTitle("More", for: .normal)
                }
            },
            onFailure: { _ in
                self.activityView?.hide(animated: true)
            }
        )
    }
}

protocol TradeItWelcomeViewControllerDelegate: class {
    func getStartedButtonWasTapped(_ fromViewController: TradeItWelcomeViewController)
}

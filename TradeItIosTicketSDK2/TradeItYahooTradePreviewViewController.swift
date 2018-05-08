import UIKit
import MBProgressHUD
import BEMCheckBox
import SafariServices

// TODO: Move DataSource
// TODO: Make sure QUANTITY TYPE works
class TradeItYahooTradePreviewViewController:
    TradeItYahooViewController,
    UITableViewDelegate,
    PreviewMessageDelegate {

    private let tradeItViewControllerProvider = TradeItViewControllerProvider(storyboardName: "TradeIt")

    @IBOutlet weak var orderDetailsTable: UITableView!
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var editOrderButton: UIButton!
    @IBOutlet weak var actionButtonWidthConstraint: NSLayoutConstraint!

    var linkedBrokerAccount: TradeItLinkedBrokerAccount!
    var previewOrderResult: TradeItPreviewOrderResult? // TODO: REMOVE
//    var placeOrderResult: TradeItPlaceOrderResult?  // TODO: REMOVE
    var placeOrderCallback: TradeItPlaceOrderHandlers?
    let alertManager = TradeItAlertManager(linkBrokerUIFlow: TradeItYahooLinkBrokerUIFlow())
    var orderCapabilities: TradeItInstrumentOrderCapabilities?
    weak var delegate: TradeItYahooTradePreviewViewControllerDelegate?
    var dataSource: EquityPreviewDataSource? // TODO: Make protocol and pass in for crypto support

    private let actionButtonTitleTextSubmitOrder = "Submit order"
    private let actionButtonTitleTextGoToOrders = "View order status"

    override func viewDidLoad() {
        super.viewDidLoad()

        precondition(self.linkedBrokerAccount != nil, "TradeItSDK ERROR: TradeItYahooTradingPreviewViewController loaded without setting linkedBrokerAccount.")

        self.title = "Preview order"
        self.statusLabel.text = "Order details"
        self.statusLabel.textColor = UIColor.yahooTextColor
        self.actionButton.setTitle(self.actionButtonTitleTextSubmitOrder, for: .normal)

        self.dataSource = EquityPreviewDataSource(
            previewMessageDelegate: self,
            linkedBrokerAccount: self.linkedBrokerAccount,
            previewOrderResult: previewOrderResult
        )
        self.orderDetailsTable.dataSource = self.dataSource
        self.orderDetailsTable.delegate = self
        let bundle = TradeItBundleProvider.provide()
        self.orderDetailsTable.register(
            UINib(nibName: "TradeItPreviewMessageTableViewCell", bundle: bundle),
            forCellReuseIdentifier: "PREVIEW_MESSAGE_CELL_ID"
        )
        
        updatePlaceOrderButtonStatus()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.fireViewEventNotification(view: .preview, title: self.title)
    }

    private func updateOrderDetailsTable(withWarningsAndAcknowledgment: Bool = true) {
        self.dataSource?.generatePreviewCellData(withWarningsAndAcknowledgment: withWarningsAndAcknowledgment)
        self.orderDetailsTable.reloadData()
    }

    // MARK: IBActions

    private func submitOrder() {
        self.fireButtonTapEventNotification(view: .preview, button: .submitOrder)

        guard let placeOrderCallback = self.placeOrderCallback else {
            print("TradeItSDK ERROR: placeOrderCallback not set on TradeItYahooTradePreviewViewController")
            return
        }

        self.actionButton.disable()

        let activityView = MBProgressHUD.showAdded(to: self.view, animated: true)
        activityView.label.text = "Authenticating"

        self.linkedBrokerAccount?.linkedBroker?.authenticateIfNeeded(
            onSuccess: {
                activityView.label.text = "Placing order"

                placeOrderCallback(
                    { placeOrderResult in
                        // Remove the editOrderButton and expand the action button
                        self.navigationController?.viewControllers = [self]
                        self.editOrderButton.removeFromSuperview()
                        self.actionButtonWidthConstraint = NSLayoutConstraint(
                            item: self.actionButton,
                            attribute: .trailing,
                            relatedBy: .equal,
                            toItem: self.actionButton.superview,
                            attribute: .trailingMargin,
                            multiplier: 1.0,
                            constant: 0
                        )
                        NSLayoutConstraint.activate([self.actionButtonWidthConstraint])

                        self.title = "Order confirmation"

                        self.statusLabel.text = "✓ Order submitted"
                        self.statusLabel.textColor = UIColor.yahooGreenSuccessColor

                        self.actionButton.enable()
                        self.actionButton.setTitle(self.actionButtonTitleTextGoToOrders, for: .normal)

                        self.dataSource = EquityPreviewDataSource(
                            previewMessageDelegate: self,
                            linkedBrokerAccount: self.linkedBrokerAccount,
                            previewOrderResult: self.previewOrderResult,
                            placeOrderResult: placeOrderResult
                        )
                        self.orderDetailsTable.dataSource = self.dataSource
                        self.updateOrderDetailsTable(withWarningsAndAcknowledgment: false)

                        activityView.hide(animated: true)

                        self.fireViewEventNotification(view: .submitted)
                    },
                    { securityQuestion, answerSecurityQuestion, cancelSecurityQuestion in
                        self.alertManager.promptUserToAnswerSecurityQuestion(
                            securityQuestion,
                            onViewController: self,
                            onAnswerSecurityQuestion: answerSecurityQuestion,
                            onCancelSecurityQuestion: cancelSecurityQuestion
                        )
                    },
                    { errorResult in
                        activityView.hide(animated: true)

                        self.actionButton.enable()

                        guard let linkedBroker = self.linkedBrokerAccount.linkedBroker else {
                            return self.alertManager.showError(
                                errorResult,
                                onViewController: self
                            )
                        }

                        self.alertManager.showAlertWithAction(
                            error: errorResult,
                            withLinkedBroker: linkedBroker,
                            onViewController: self
                        )
                    }
                )
            },
            onSecurityQuestion: { securityQuestion, answerSecurityQuestion, cancelSecurityQuestion in
                activityView.hide(animated: true)
                self.alertManager.promptUserToAnswerSecurityQuestion(
                    securityQuestion,
                    onViewController: self,
                    onAnswerSecurityQuestion: answerSecurityQuestion,
                    onCancelSecurityQuestion: cancelSecurityQuestion
                )
            },
            onFailure: { errorResult in
                activityView.hide(animated: true)
                self.actionButton.enable()
                
                guard let linkedBroker = self.linkedBrokerAccount.linkedBroker else {
                    return self.alertManager.showError(
                        errorResult,
                        onViewController: self
                    )
                }
                
                self.alertManager.showAlertWithAction(
                    error: errorResult,
                    withLinkedBroker: linkedBroker,
                    onViewController: self
                )
            }
        )
    }

    @IBAction func actionButtonTapped(_ sender: UIButton) {
        if self.dataSource?.isOrderPlaced == true {
            self.fireButtonTapEventNotification(view: .submitted, button: .viewOrderStatus)
            if let navigationController = self.navigationController {
                guard let ordersViewController = self.tradeItViewControllerProvider.provideViewController(forStoryboardId: TradeItStoryboardID.ordersView) as? TradeItOrdersViewController else { return }
                ordersViewController.enableThemeOnLoad = false
                ordersViewController.enableCustomNavController()
                ordersViewController.linkedBrokerAccount = linkedBrokerAccount
                navigationController.setViewControllers([ordersViewController], animated: true)
            }
        } else {
            self.submitOrder()
        }
    }

    @IBAction func editOrderButtonTapped(_ sender: Any) {
        self.fireButtonTapEventNotification(view: .preview, button: .editOrder)
        _ = navigationController?.popViewController(animated: true)
    }

    // MARK: PreviewMessageDelegate

    func acknowledgementWasChanged() {
        updatePlaceOrderButtonStatus()
    }

    func launchLink(url: String) {
        guard let url = URL(string: url) else { return }
        if ["http", "https"].contains(url.scheme?.lowercased() ?? "") {
            let safariViewController = SFSafariViewController(url: url)
            self.present(safariViewController, animated: true, completion: nil)
        } else {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
    
    // MARK: Private
    
    private func updatePlaceOrderButtonStatus() {
        if self.dataSource?.allAcknowledgementsAccepted() == true {
            self.actionButton.enable()
        } else {
            self.actionButton.disable()
        }
    }
}

protocol TradeItYahooTradePreviewViewControllerDelegate: class {
    func viewPortfolioTapped(
        onTradePreviewViewController tradePreviewViewController: TradeItYahooTradePreviewViewController,
        linkedBrokerAccount: TradeItLinkedBrokerAccount
    )
}

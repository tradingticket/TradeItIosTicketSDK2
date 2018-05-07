import UIKit
import MBProgressHUD
import BEMCheckBox
import SafariServices

class TradeItYahooTradePreviewViewController:
    TradeItYahooViewController,
    UITableViewDelegate,
    UITableViewDataSource,
    PreviewMessageDelegate {

    private let tradeItViewControllerProvider = TradeItViewControllerProvider(storyboardName: "TradeIt")

    @IBOutlet weak var orderDetailsTable: UITableView!
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var editOrderButton: UIButton!
    @IBOutlet weak var actionButtonWidthConstraint: NSLayoutConstraint!

    var linkedBrokerAccount: TradeItLinkedBrokerAccount!
    var previewOrderResult: TradeItPreviewOrderResult?
    var placeOrderResult: TradeItPlaceOrderResult?
    var placeOrderCallback: TradeItPlaceOrderHandlers?
    var previewCellData = [PreviewCellData]()
    let alertManager = TradeItAlertManager(linkBrokerUIFlow: TradeItYahooLinkBrokerUIFlow())
    var orderCapabilities: TradeItInstrumentOrderCapabilities?
    weak var delegate: TradeItYahooTradePreviewViewControllerDelegate?

    private let actionButtonTitleTextSubmitOrder = "Submit order"
    private let actionButtonTitleTextGoToOrders = "View order status"

    override func viewDidLoad() {
        super.viewDidLoad()

        precondition(self.linkedBrokerAccount != nil, "TradeItSDK ERROR: TradeItYahooTradingPreviewViewController loaded without setting linkedBrokerAccount.")

        self.title = "Preview order"
        self.statusLabel.text = "Order details"
        self.statusLabel.textColor = UIColor.yahooTextColor
        self.actionButton.setTitle(self.actionButtonTitleTextSubmitOrder, for: .normal)
        self.orderCapabilities = self.linkedBrokerAccount.orderCapabilities.filter { $0.instrument == "equities" }.first
        self.previewCellData = self.generatePreviewCellData()
        
        orderDetailsTable.dataSource = self
        orderDetailsTable.delegate = self
        let bundle = TradeItBundleProvider.provide()
        orderDetailsTable.register(
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
        self.previewCellData = self.generatePreviewCellData(withWarningsAndAcknowledgment: withWarningsAndAcknowledgment)
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
                        //Remove the editOrderButton and expand the action button
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
                        
                        self.placeOrderResult = placeOrderResult

                        self.title = "Order confirmation"

                        self.statusLabel.text = "✓ Order submitted"
                        self.statusLabel.textColor = UIColor.yahooGreenSuccessColor

                        self.actionButton.enable()
                        self.actionButton.setTitle(self.actionButtonTitleTextGoToOrders, for: .normal)

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
        if self.placeOrderResult != nil {
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

    // MARK: UITableViewDataSource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return previewCellData.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellData = previewCellData[indexPath.row]

        switch cellData {
        case let messageCellData as MessageCellData:
            let cell = tableView.dequeueReusableCell(withIdentifier: "PREVIEW_MESSAGE_CELL_ID") as! TradeItPreviewMessageTableViewCell
            cell.populate(withCellData: messageCellData, andDelegate: self)
            return cell
        case let valueCellData as ValueCellData:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TRADE_IT_YAHOO_PREVIEW_CELL_ID") ?? UITableViewCell()
            cell.textLabel?.text = valueCellData.label
            cell.detailTextLabel?.text = valueCellData.value

            return cell
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
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
        if allAcknowledgementsAccepted() {
            self.actionButton.enable()
        } else {
            self.actionButton.disable()
        }
    }
    
    private func allAcknowledgementsAccepted() -> Bool {
        return previewCellData.compactMap { $0 as? MessageCellData }.filter { !$0.isValid() }.count == 0
    }
    
    private func generatePreviewCellData(withWarningsAndAcknowledgment: Bool = true) -> [PreviewCellData] {
        guard let linkedBrokerAccount = linkedBrokerAccount,
            let orderDetails = previewOrderResult?.orderDetails
            else { return [] }

        var cells = [PreviewCellData]()

        cells += [
            ValueCellData(label: "Account", value: linkedBrokerAccount.getFormattedAccountName())
        ] as [PreviewCellData]

        let orderDetailsPresenter = TradeItOrderDetailsPresenter(orderDetails: orderDetails, orderCapabilities: orderCapabilities)

        if let orderNumber = self.placeOrderResult?.orderNumber {
            cells += [
                ValueCellData(label: "Order #", value: orderNumber)
            ] as [PreviewCellData]
        }

        cells += [
            ValueCellData(label: "Action", value: orderDetailsPresenter.getOrderActionLabel()),
            ValueCellData(label: "Symbol", value: orderDetails.orderSymbol),
            ValueCellData(label: "Shares", value: NumberFormatter.formatQuantity(orderDetails.orderQuantity)),
            ValueCellData(label: "Price", value: orderDetails.orderPrice),
            ValueCellData(label: "Time in force", value: orderDetailsPresenter.getOrderExpirationLabel())
        ] as [PreviewCellData]

        if self.linkedBrokerAccount.userCanDisableMargin {
            cells.append(ValueCellData(label: "Type", value: MarginPresenter.labelFor(value: orderDetailsPresenter.userDisabledMargin)))
        }

        if let estimatedOrderCommission = orderDetails.estimatedOrderCommission {
            cells.append(ValueCellData(label: orderDetails.orderCommissionLabel, value: self.formatCurrency(estimatedOrderCommission)))
        }

        if let estimatedTotalValue = orderDetails.estimatedTotalValue {
            let action = TradeItOrderAction(value: orderDetails.orderAction)
            let title = "Estimated \(TradeItOrderActionPresenter.SELL_ACTIONS.contains(action) ? "proceeds" : "cost")"
            cells.append(ValueCellData(label: title, value: formatCurrency(estimatedTotalValue)))
        }
        
        if withWarningsAndAcknowledgment {
            cells += generateMessageCellData()
        }

        return cells
    }

    private func generateMessageCellData() -> [PreviewCellData] {
        guard let messages = previewOrderResult?.orderDetails?.warnings else { return [] }
        return messages.map(MessageCellData.init)
    }

    private func formatCurrency(_ value: NSNumber) -> String {
        return NumberFormatter.formatCurrency(value, currencyCode: self.linkedBrokerAccount.accountBaseCurrency)
    }
}

protocol TradeItYahooTradePreviewViewControllerDelegate: class {
    func viewPortfolioTapped(
        onTradePreviewViewController tradePreviewViewController: TradeItYahooTradePreviewViewController,
        linkedBrokerAccount: TradeItLinkedBrokerAccount
    )
}

import UIKit
import MBProgressHUD
import SafariServices

@objc internal protocol PreviewCellData {}

internal class MessageCellData: PreviewCellData {
    let message: TradeItPreviewMessage
    var isAcknowledged = false

    init(message: TradeItPreviewMessage) {
        self.message = message
    }

    func isValid() -> Bool {
        return !message.requiresAcknowledgement || isAcknowledged
    }
}

internal class ValueCellData: PreviewCellData {
    let label: String
    let value: String

    init(label: String, value: String) {
        self.label = label
        self.value = value
    }
}

internal class BrandedAccountNameCellData: PreviewCellData {
    let linkedBroker: TradeItLinkedBrokerAccount

    init(linkedBroker: TradeItLinkedBrokerAccount) {
        self.linkedBroker = linkedBroker
    }
}

class TradeItTradePreviewViewController:
    TradeItViewController,
    UITableViewDelegate,
    UITableViewDataSource,
    PreviewMessageDelegate {
    @IBOutlet weak var orderDetailsTable: UITableView!
    @IBOutlet weak var placeOrderButton: UIButton!
    @IBOutlet weak var adContainer: UIView!

    var linkedBrokerAccount: TradeItLinkedBrokerAccount!
    var previewOrderResult: TradeItPreviewOrderResult?
    var placeOrderCallback: TradeItPlaceOrderHandlers?
    var previewCellData: [PreviewCellData] = []
    var messageCellData: [MessageCellData] = []
    var alertManager = TradeItAlertManager()
    var orderCapabilities: TradeItInstrumentOrderCapabilities?
    
    weak var delegate: TradeItTradePreviewViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        precondition(self.linkedBrokerAccount != nil, "TradeItIosTicketSDK ERROR: TradeItTradingPreviewViewController loaded without setting linkedBrokerAccount.")
        
        self.orderCapabilities = self.linkedBrokerAccount.orderCapabilities.filter { $0.instrument == "equities" }.first
        previewCellData = generatePreviewCellData()

        orderDetailsTable.dataSource = self
        orderDetailsTable.delegate = self
        
        updatePlaceOrderButtonStatus()

        TradeItBundleProvider.registerPreviewMessageNibCells(forTableView: orderDetailsTable)
        TradeItBundleProvider.registerBrandedAccountNibCells(forTableView: orderDetailsTable)

        TradeItSDK.adService.populate(
            adContainer: adContainer,
            rootViewController: self,
            pageType: .preview,
            position: .bottom,
            broker: linkedBrokerAccount?.brokerName,
            symbol: previewOrderResult?.orderDetails?.orderSymbol,
            instrumentType: TradeItTradeInstrumentType.equities.rawValue,
            trackPageViewAsPageType: true
        )
    }

    @IBAction func placeOrderTapped(_ sender: UIButton) {
        guard let placeOrderCallback = placeOrderCallback else {
            print("TradeIt SDK ERROR: placeOrderCallback not set!")
            return
        }

        let activityView = MBProgressHUD.showAdded(to: self.view, animated: true)
        activityView.label.text = "Placing Order"

        placeOrderCallback(
            { result in
                activityView.hide(animated: true)
                self.delegate?.orderSuccessfullyPlaced(onTradePreviewViewController: self, withPlaceOrderResult: result)
            },
            { securityQuestion, answerSecurityQuestion, cancelSecurityQuestion in
                self.alertManager.promptUserToAnswerSecurityQuestion(
                    securityQuestion,
                    onViewController: self,
                    onAnswerSecurityQuestion: answerSecurityQuestion,
                    onCancelSecurityQuestion: cancelSecurityQuestion
                )
            },
            { error in
                activityView.hide(animated: true)
                guard let linkedBroker = self.linkedBrokerAccount.linkedBroker else {
                    return self.alertManager.showError(
                        error,
                        onViewController: self
                    )
                }

                self.alertManager.showAlertWithAction(
                    error: error,
                    withLinkedBroker: linkedBroker,
                    onViewController: self
                )
            }
        )
    }

    // MARK: UITableViewDataSource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.previewCellData.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellData = self.previewCellData[indexPath.row]

        switch cellData {
        case let messageCellData as MessageCellData:
            let cell = tableView.dequeueReusableCell(withIdentifier: "PREVIEW_MESSAGE_CELL_ID") as! TradeItPreviewMessageTableViewCell
            cell.populate(withCellData: messageCellData, andDelegate: self)
            return cell
        case let valueCellData as ValueCellData:
            let cell = tableView.dequeueReusableCell(withIdentifier: "PREVIEW_ORDER_VALUE_CELL_ID") as! TradeItPreviewOrderValueTableViewCell
            cell.populate(withLabel: valueCellData.label, andValue: valueCellData.value)
            return cell
        case let accountNameCellData as BrandedAccountNameCellData:
            let cell = tableView.dequeueReusableCell(withIdentifier: "BRANDED_ACCOUNT_NAME_CELL_ID") as! TradeItPreviewBrandedAccountNameCell
            cell.populate(linkedBroker: accountNameCellData.linkedBroker)
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
            self.placeOrderButton.enable()
        } else {
            self.placeOrderButton.disable()
        }
    }

    private func allAcknowledgementsAccepted() -> Bool {
        return previewCellData.compactMap { $0 as? MessageCellData }.filter { !$0.isValid() }.count == 0
    }

    private func generatePreviewCellData() -> [PreviewCellData] {
        guard let orderDetails = previewOrderResult?.orderDetails else { return [] }

        var cells: [PreviewCellData] = [
            BrandedAccountNameCellData(linkedBroker: self.linkedBrokerAccount),
        ]
        
        cells += generateMessageCellData()

        let orderDetailsPresenter = TradeItOrderDetailsPresenter(orderDetails: orderDetails, orderCapabilities: orderCapabilities)
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
            cells.append(ValueCellData(label: orderDetails.orderCommissionLabel, value: formatCurrency(estimatedOrderCommission)))
        }

        if let estimatedTotalValue = orderDetails.estimatedTotalValue {
            let action = TradeItOrderAction(value: orderDetails.orderAction)
            let title = "Estimated \(TradeItOrderActionPresenter.SELL_ACTIONS.contains(action) ? "proceeds" : "cost")"
            cells.append(ValueCellData(label: title, value: formatCurrency(estimatedTotalValue)))
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

protocol TradeItTradePreviewViewControllerDelegate: class {
    func orderSuccessfullyPlaced(onTradePreviewViewController tradePreviewViewController: TradeItTradePreviewViewController,
                                 withPlaceOrderResult placeOrderResult: TradeItPlaceOrderResult)
}

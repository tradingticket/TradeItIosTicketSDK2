import UIKit

@objc internal protocol PreviewCellData {}

internal class WarningCellData: PreviewCellData {
    let warning: String

    init(warning: String) {
        self.warning = warning
    }
}

internal class AcknowledgementCellData: PreviewCellData {
    let acknowledgement: String
    var isAcknowledged = false

    init(acknowledgement: String) {
        self.acknowledgement = acknowledgement
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

class TradeItTradePreviewViewController: TradeItViewController, UITableViewDelegate, UITableViewDataSource, AcknowledgementDelegate {
    @IBOutlet weak var orderDetailsTable: UITableView!
    @IBOutlet weak var placeOrderButton: UIButton!

    var ezLoadingActivityManager = EZLoadingActivityManager()
    var linkedBrokerAccount: TradeItLinkedBrokerAccount!
    var previewOrder: TradeItPreviewTradeResult?
    var placeOrderCallback: TradeItPlaceOrderHandlers?
    var previewCellData: [PreviewCellData] = []
    var acknowledgementCellData: [AcknowledgementCellData] = []
    var alertManager = TradeItAlertManager()

    weak var delegate: TradeItTradePreviewViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if self.linkedBrokerAccount == nil {
            assertionFailure("TradeItIosTicketSDK ERROR: TradeItTradingPreviewViewController loaded without setting linkedBrokerAccount.")
        }

        previewCellData = generatePreviewCellData()

        orderDetailsTable.dataSource = self
        orderDetailsTable.delegate = self
        updatePlaceOrderButtonStatus()
    }

    @IBAction func placeOrderTapped(sender: UIButton) {
        guard let placeOrderCallback = placeOrderCallback else {
            print("TradeIt SDK ERROR: placeOrderCallback not set!")
            return
        }

        self.ezLoadingActivityManager.show(text: "Placing Order", disableUI: true)

        placeOrderCallback(onSuccess: { result in
            self.ezLoadingActivityManager.hide()
            self.delegate?.tradeItTradePreviewViewController(self, didPlaceOrderWithResult: result)
            
        }, onFailure: { errorResult in
            self.ezLoadingActivityManager.hide()
            self.alertManager.show(tradeItErrorResult: errorResult,
                                            onViewController: self,
                                            withLinkedBroker: self.linkedBrokerAccount.linkedBroker,
                                            onFinished: {})
        })
    }

    // MARK: UITableViewDelegate

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    }

    // MARK: UITableViewDataSource

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return previewCellData.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellData = previewCellData[indexPath.row]

        switch cellData {
        case let warningCellData as WarningCellData:
            let cell = tableView.dequeueReusableCellWithIdentifier("PREVIEW_ORDER_WARNING_CELL_ID") as! TradeItPreviewOrderWarningTableViewCell
            cell.populate(withWarning: warningCellData.warning)
            return cell
        case let acknowledgementCellData as AcknowledgementCellData:
            let cell = tableView.dequeueReusableCellWithIdentifier("PREVIEW_ORDER_ACKNOWLEDGEMENT_CELL_ID") as! TradeItPreviewOrderAcknowledgementTableViewCell
            cell.populate(withCellData: acknowledgementCellData, andDelegate: self)
            return cell
        case let valueCellData as ValueCellData:
            let cell = tableView.dequeueReusableCellWithIdentifier("PREVIEW_ORDER_VALUE_CELL_ID") as! TradeItPreviewOrderValueTableViewCell
            cell.populate(withLabel: valueCellData.label, andValue: valueCellData.value)
            return cell
        default:
            return UITableViewCell()
        }
    }

    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

    // MARK: AcknowledgementDelegate

    func acknowledgementWasChanged() {
        updatePlaceOrderButtonStatus()
    }

    // MARK: Private

    private func updatePlaceOrderButtonStatus() {
        if allAcknowledgementsAccepted() {
            placeOrderButton.enabled = true
            placeOrderButton.backgroundColor = UIColor.tradeItClearBlueColor()
        } else {
            placeOrderButton.enabled = false
            placeOrderButton.backgroundColor = UIColor.tradeItGreyishBrownColor()
        }
    }

    private func allAcknowledgementsAccepted() -> Bool {
        return acknowledgementCellData.filter{ !$0.isAcknowledged }.count == 0
    }

    private func generatePreviewCellData() -> [PreviewCellData] {
        guard let linkedBrokerAccount = linkedBrokerAccount,
            let orderDetails = previewOrder?.orderDetails
            else { return [] }

        var cells: [PreviewCellData] = []

        cells += generateWarningCellData()

        acknowledgementCellData = generateAcknowledgementCellData()
        cells += acknowledgementCellData as [PreviewCellData]

        cells += [
            ValueCellData(label: "ACCOUNT", value: linkedBrokerAccount.accountName),
            ValueCellData(label: "SYMBOL", value: orderDetails.orderSymbol),
            ValueCellData(label: "QUANTITY", value: NumberFormatter.formatQuantity(orderDetails.orderQuantity.floatValue)),
            ValueCellData(label: "ACTION", value: orderDetails.orderAction),
            ValueCellData(label: "PRICE", value: orderDetails.orderPrice),
            ValueCellData(label: "EXPIRATION", value: orderDetails.orderExpiration)
        ] as [PreviewCellData]

        if let longHoldings = orderDetails.longHoldings {
            cells.append(ValueCellData(label: "SHARES OWNED", value: NumberFormatter.formatQuantity(longHoldings.floatValue)))
        }

        if let shortHoldings = orderDetails.shortHoldings {
            cells.append(ValueCellData(label: "SHARES HELD SHORT", value: NumberFormatter.formatQuantity(shortHoldings.floatValue)))
        }

        if let buyingPower = orderDetails.buyingPower {
            cells.append(ValueCellData(label: "BUYING POWER", value: NumberFormatter.formatCurrency(buyingPower)))
        }

        if let estimatedOrderCommission = orderDetails.estimatedOrderCommission {
            cells.append(ValueCellData(label: "BROKER FEE", value: NumberFormatter.formatCurrency(estimatedOrderCommission)))
        }

        if let estimatedTotalValue = orderDetails.estimatedTotalValue {
            cells.append(ValueCellData(label: "ESTIMATED COST", value: NumberFormatter.formatCurrency(estimatedTotalValue)))
        }

        return cells
    }

    private func generateWarningCellData() -> [PreviewCellData] {
        guard let warnings = previewOrder?.warningsList as? [String] else { return [] }

        return warnings.map({ warning in
            return WarningCellData(warning: warning)
        })
    }

    private func generateAcknowledgementCellData() -> [AcknowledgementCellData] {
        guard let acknowledgements = previewOrder?.ackWarningsList as? [String] else { return [] }

        return acknowledgements.map({ acknowledgement in
            return AcknowledgementCellData(acknowledgement: acknowledgement)
        })
    }
}

protocol TradeItTradePreviewViewControllerDelegate: class {
    func tradeItTradePreviewViewController(tradeItTradePreviewViewController: TradeItTradePreviewViewController,
                                           didPlaceOrderWithResult placeOrderResult: TradeItPlaceOrderResult)
}

import UIKit

protocol TradeItPreviewCellData {}

class TradeItTradingPreviewViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var orderDetailsTable: UITableView!

    var ezLoadingActivityManager = EZLoadingActivityManager()
    var linkedBrokerAccount: TradeItLinkedBrokerAccount!
    var previewOrder: TradeItPreviewTradeResult?
    var placeOrderCallback: TradeItPlaceOrderHandlers?
    var previewCellData: [TradeItPreviewCellData] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        if self.linkedBrokerAccount == nil {
            assertionFailure("TradeItIosTicketSDK ERROR: TradeItTradingPreviewViewController loaded without setting linkedBrokerAccount.")
        }

        previewCellData = generatePreviewCellData()

        orderDetailsTable.dataSource = self
        orderDetailsTable.delegate = self
        orderDetailsTable.rowHeight = UITableViewAutomaticDimension
    }

    @IBAction func placeOrderTapped(sender: UIButton) {
        guard let placeOrderCallback = placeOrderCallback else { return }

        self.ezLoadingActivityManager.show(text: "Placing Order", disableUI: true)

        placeOrderCallback(onSuccess: { result in
            let storyboard = UIStoryboard(name: "TradeIt", bundle: TradeItBundleProvider.provide())
            let tradingConfirmationViewController = storyboard.instantiateViewControllerWithIdentifier(TradeItStoryboardID.tradingConfirmationView.rawValue) as! TradeItTradingConfirmationViewController

            tradingConfirmationViewController.placeOrderResult = result

            self.navigationController?.setViewControllers([tradingConfirmationViewController], animated: true)
            self.ezLoadingActivityManager.hide()
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

    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
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
            cell.populate(withAcknowledgement: acknowledgementCellData.acknowledgement)
            return cell
        case let valueCellData as ValueCellData:
            let cell = tableView.dequeueReusableCellWithIdentifier("PREVIEW_ORDER_VALUE_CELL_ID") as! TradeItPreviewOrderValueTableViewCell
            cell.populate(withLabel: valueCellData.label, andValue: valueCellData.value)
            return cell
        default:
            return UITableViewCell()
        }
    }

    // MARK: Private

    private func generatePreviewCellData() -> [TradeItPreviewCellData] {
        guard let linkedBrokerAccount = linkedBrokerAccount,
            let orderDetails = previewOrder?.orderDetails
            else { return [] }

        var cells: [TradeItPreviewCellData] = []

        cells.appendContentsOf(generateWarningCellData())
        cells.appendContentsOf(generateAcknowledgementCellData())

        cells.appendContentsOf([
            ValueCellData(label: "ACCOUNT", value: linkedBrokerAccount.accountName),
            ValueCellData(label: "SYMBOL", value: orderDetails.orderSymbol),
            ValueCellData(label: "QUANTITY", value: NumberFormatter.formatQuantity(orderDetails.orderQuantity.floatValue)),
            ValueCellData(label: "ACTION", value: orderDetails.orderAction),
            ValueCellData(label: "PRICE", value: orderDetails.orderPrice),
            ValueCellData(label: "EXPIRATION", value: orderDetails.orderExpiration)
        ] as [TradeItPreviewCellData])

        if orderDetails.longHoldings != nil {
            cells.append(
                ValueCellData(label: "SHARES OWNED", value: NumberFormatter.formatQuantity(orderDetails.longHoldings.floatValue))
            )
        }

        if orderDetails.shortHoldings != nil {
            cells.append(ValueCellData(
                label: "SHARES HELD SHORT",
                value: NumberFormatter.formatQuantity(orderDetails.shortHoldings.floatValue)
            ))
        }

        if orderDetails.buyingPower != nil {
            cells.append(ValueCellData(
                label: "BUYING POWER",
                value: NumberFormatter.formatCurrency(orderDetails.buyingPower)
            ))
        }

        if orderDetails.estimatedOrderCommission != nil {
            cells.append(
                ValueCellData(label: "BROKER FEE", value: NumberFormatter.formatCurrency(orderDetails.estimatedOrderCommission))
            )
        }

        if orderDetails.estimatedTotalValue != nil {
            cells.append(
                ValueCellData(label: "ESTIMATED COST", value: NumberFormatter.formatCurrency(orderDetails.estimatedTotalValue))
            )
        }

        return cells
    }

    private func generateWarningCellData() -> [TradeItPreviewCellData] {
        guard let warnings = previewOrder?.warningsList as? [String] else { return [] }

        return warnings.map({ warning in
            return WarningCellData(warning: warning)
        })
    }

    private func generateAcknowledgementCellData() -> [TradeItPreviewCellData] {
        guard let acknowledgements = previewOrder?.ackWarningsList as? [String] else { return [] }

        return acknowledgements.map({ acknowledgement in
            return AcknowledgementCellData(acknowledgement: acknowledgement)
        })
    }

    class WarningCellData: TradeItPreviewCellData {
        let warning: String

        init(warning: String) {
            self.warning = warning
        }
    }

    class AcknowledgementCellData: TradeItPreviewCellData {
        let acknowledgement: String

        init(acknowledgement: String) {
            self.acknowledgement = acknowledgement
        }
    }

    class ValueCellData: TradeItPreviewCellData {
        let label: String
        let value: String

        init(label: String, value: String) {
            self.label = label
            self.value = value
        }
    }
}

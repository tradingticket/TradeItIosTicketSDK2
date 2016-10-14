import UIKit

class TradeItTradingPreviewViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var orderDetailsTable: UITableView!

    var ezLoadingActivityManager = EZLoadingActivityManager()
    var linkedBrokerAccount: TradeItLinkedBrokerAccount!
    var previewOrder: TradeItPreviewTradeResult?
    var placeOrderCallback: TradeItPlaceOrderHandlers?
    var previewData: [TableData] = [] // TODO: Move to presenter?
    var alertManager =  TradeItAlertManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if self.linkedBrokerAccount == nil {
            assertionFailure("TradeItIosTicketSDK ERROR: TradeItTradingPreviewViewController loaded without setting linkedBrokerAccount.")
        }
        previewData = generateTableData()

        orderDetailsTable.dataSource = self
        orderDetailsTable.delegate = self
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

    // MARK: UITableViewDataSource

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return previewData.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ORDER_PREVIEW_CELL_ID") as! TradeItOrderPreviewTableViewCell
        cell.selectionStyle = .None
        let dataForRow = previewData[indexPath.row]
        cell.populate(withLabel: dataForRow.label, andValue: dataForRow.value)
        return cell
    }

    // MARK: Private

    private func generateTableData() -> [TableData] {
        guard let linkedBrokerAccount = linkedBrokerAccount,
            let previewOrder = previewOrder,
            let orderDetails = previewOrder.orderDetails
            else { return [] }

        var rows = [
            TableData(label: "Account", value: linkedBrokerAccount.accountName),
            TableData(label: "Symbol", value: orderDetails.orderSymbol),
            TableData(label: "Quantity", value: NumberFormatter.formatQuantity(orderDetails.orderQuantity.floatValue)),
            TableData(label: "Action", value: orderDetails.orderAction),
            TableData(label: "Price", value: orderDetails.orderPrice),
            TableData(label: "Expiration", value: orderDetails.orderExpiration)
        ]

        if orderDetails.longHoldings != nil {
            rows.append(
                TableData(label: "Shares Owned", value: NumberFormatter.formatQuantity(orderDetails.longHoldings!.floatValue))
            )
        }

        if orderDetails.shortHoldings != nil {
            rows.append(TableData(
                label: "Shares Held Short",
                value: NumberFormatter.formatQuantity(orderDetails.shortHoldings!.floatValue)
            ))
        }

        if orderDetails.buyingPower != nil {
            rows.append(TableData(
                label: "Buying Power",
                value: NumberFormatter.formatCurrency(orderDetails.buyingPower!)
            ))
        }

        if orderDetails.estimatedOrderCommission != nil {
            rows.append(
                TableData(label: "Broker Fee", value: NumberFormatter.formatCurrency(orderDetails.estimatedOrderCommission!))
            )
        }

        if orderDetails.estimatedTotalValue != nil {
            rows.append(
                TableData(label: "Estimated Cost", value: NumberFormatter.formatCurrency(orderDetails.estimatedTotalValue!))
            )
        }

        return rows
    }

    class TableData {
        var label: String
        var value: String

        init(label: String, value: String) {
            self.label = label
            self.value = value
        }
    }
}

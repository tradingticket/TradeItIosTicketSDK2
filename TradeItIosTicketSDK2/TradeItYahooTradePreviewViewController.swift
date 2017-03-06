import UIKit

class TradeItYahooTradePreviewViewController: CloseableViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var brokerLabel: UILabel!
    @IBOutlet weak var orderDetailsTable: UITableView!
    @IBOutlet weak var submitOrderButton: UIButton!

    var linkedBrokerAccount: TradeItLinkedBrokerAccount!
    var previewOrderResult: TradeItPreviewOrderResult?
    var placeOrderCallback: TradeItPlaceOrderHandlers?
    var previewCellData = [PreviewCellData]()
//    var acknowledgementCellData: [AcknowledgementCellData] = []
    var alertManager = TradeItAlertManager()

    override func viewDidLoad() {
        super.viewDidLoad()

        precondition(self.linkedBrokerAccount != nil, "ERROR: TradeItYahooTradingPreviewViewController loaded without setting linkedBrokerAccount.")

        self.title = "Preview order"
        self.brokerLabel.text = self.linkedBrokerAccount.brokerName

        self.previewCellData = self.generatePreviewCellData()

        orderDetailsTable.dataSource = self
        orderDetailsTable.delegate = self
    }

    // MARK: UITableViewDelegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }

    // MARK: UITableViewDataSource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return previewCellData.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellData = previewCellData[indexPath.row]

        switch cellData {
//        case let warningCellData as WarningCellData:
//            let cell = tableView.dequeueReusableCell(withIdentifier: "PREVIEW_ORDER_WARNING_CELL_ID") as! TradeItPreviewOrderWarningTableViewCell
//            cell.populate(withWarning: warningCellData.warning)
//            return cell
//        case let acknowledgementCellData as AcknowledgementCellData:
//            let cell = tableView.dequeueReusableCell(withIdentifier: "PREVIEW_ORDER_ACKNOWLEDGEMENT_CELL_ID") as! TradeItPreviewOrderAcknowledgementTableViewCell
//            cell.populate(withCellData: acknowledgementCellData, andDelegate: self)
//            return cell
        case let valueCellData as ValueCellData:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TRADE_IT_YAHOO_PREVIEW_CELL_ID") ?? UITableViewCell()
            cell.textLabel?.text = valueCellData.label
            cell.detailTextLabel?.text = valueCellData.value

            return cell
        default:
            return UITableViewCell()
        }
    }

//    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
//        return UITableViewAutomaticDimension
//    }
//
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return UITableViewAutomaticDimension
//    }


    // MARK: Private

    private func generatePreviewCellData() -> [PreviewCellData] {
        guard let linkedBrokerAccount = linkedBrokerAccount,
            let orderDetails = previewOrderResult?.orderDetails
            else { return [] }

        var cells: [PreviewCellData] = []

//        cells += generateWarningCellData()

//        acknowledgementCellData = generateAcknowledgementCellData()
//        cells += acknowledgementCellData as [PreviewCellData]

        let orderDetailsPresenter = TradeItOrderDetailsPresenter(orderDetails: orderDetails)
        cells += [
            ValueCellData(label: "Account", value: linkedBrokerAccount.getFormattedAccountName()),
            ValueCellData(label: "Symbol", value: orderDetails.orderSymbol),
            ValueCellData(label: "Shares", value: NumberFormatter.formatQuantity(orderDetails.orderQuantity)),
            ValueCellData(label: "Action", value: orderDetailsPresenter.getOrderActionLabel()),
            ValueCellData(label: "Price", value: orderDetails.orderPrice),
            ValueCellData(label: "Time in force", value: orderDetailsPresenter.getOrderExpirationLabel())
            ] as [PreviewCellData]

        if let longHoldings = orderDetails.longHoldings {
            cells.append(ValueCellData(label: "Shares owned", value: NumberFormatter.formatQuantity(longHoldings)))
        }

        if let shortHoldings = orderDetails.shortHoldings {
            cells.append(ValueCellData(label: "Shares held short", value: NumberFormatter.formatQuantity(shortHoldings)))
        }

        if let buyingPower = orderDetails.buyingPower {
            cells.append(ValueCellData(label: "Buying power", value: self.formatCurrency(buyingPower)))
        }

        if let estimatedOrderCommission = orderDetails.estimatedOrderCommission {
            cells.append(ValueCellData(label: "Broker fee", value: self.formatCurrency(estimatedOrderCommission)))
        }

        if let estimatedTotalValue = orderDetails.estimatedTotalValue {
            cells.append(ValueCellData(label: "Estimated cost", value: self.formatCurrency(estimatedTotalValue)))
        }
        
        return cells
    }

    private func formatCurrency(_ value: NSNumber) -> String {
        return NumberFormatter.formatCurrency(value, currencyCode: TradeItPresenter.DEFAULT_CURRENCY_CODE)
    }
}

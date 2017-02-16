import UIKit

@objc class TradeItYahooTradingConfirmationViewController: CloseableViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var brokerLabel: UILabel!
    @IBOutlet weak var confirmationTable: UITableView!

    var linkedBrokerAccount: TradeItLinkedBrokerAccount!
    var previewOrderResult: TradeItPreviewOrderResult?
    var placeOrderResult: TradeItPlaceOrderResult?
    var viewControllerProvider = TradeItViewControllerProvider()
    var tradingUIFlow = TradeItTradingUIFlow()
    var previewCellData = [PreviewCellData]()

    weak var delegate: TradeItYahooTradingConfirmationViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        precondition(self.linkedBrokerAccount != nil, "ERROR: TradeItYahooTradingPreviewViewController loaded without setting linkedBrokerAccount.")

        self.title = "Order Confirmation"
        self.brokerLabel.text = self.linkedBrokerAccount.brokerName
        self.previewCellData = self.generatePreviewCellData()

        self.confirmationTable.dataSource = self
        self.confirmationTable.delegate = self
    }

//    @IBAction func tradeButtonWasTapped(_ sender: AnyObject) {
//        self.delegate?.tradeButtonWasTapped(self)
//    }

//    @IBAction func portfolioButtonWasTapped(_ sender: AnyObject) {
//        if let navigationController = self.navigationController {
//            let initialViewController = self.viewControllerProvider.provideViewController(forStoryboardId: TradeItStoryboardID.portfolioView)
//            navigationController.setViewControllers([initialViewController], animated: true)
//        }
//    }

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
        case let valueCellData as ValueCellData:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TRADE_IT_YAHOO_PREVIEW_CELL_ID") ?? UITableViewCell()
            cell.textLabel?.text = valueCellData.label
            cell.detailTextLabel?.text = valueCellData.value

            return cell
        default:
            return UITableViewCell()
        }
    }

    // MARK: Private

    private func generatePreviewCellData() -> [PreviewCellData] {
        guard let linkedBrokerAccount = linkedBrokerAccount
            , let orderDetails = previewOrderResult?.orderDetails
            , let placeOrderResult = placeOrderResult
            , let orderNumber = placeOrderResult.orderNumber
            else { return [] }

        var cells: [PreviewCellData] = []

        let orderDetailsPresenter = TradeItOrderDetailsPresenter(orderDetails: orderDetails)
        cells += [
            ValueCellData(label: "ACCOUNT", value: linkedBrokerAccount.getFormattedAccountName()),
            ValueCellData(label: "ORDER #", value: orderNumber),
            ValueCellData(label: "SYMBOL", value: orderDetails.orderSymbol),
            ValueCellData(label: "QUANTITY", value: NumberFormatter.formatQuantity(orderDetails.orderQuantity)),
            ValueCellData(label: "ACTION", value: orderDetailsPresenter.getOrderActionLabel()),
            ValueCellData(label: "PRICE", value: orderDetails.orderPrice),
            ValueCellData(label: "EXPIRATION", value: orderDetailsPresenter.getOrderExpirationLabel())
            ] as [PreviewCellData]

        if let longHoldings = orderDetails.longHoldings {
            cells.append(ValueCellData(label: "SHARES OWNED", value: NumberFormatter.formatQuantity(longHoldings)))
        }

        if let shortHoldings = orderDetails.shortHoldings {
            cells.append(ValueCellData(label: "SHARES HELD SHORT", value: NumberFormatter.formatQuantity(shortHoldings)))
        }

        if let buyingPower = orderDetails.buyingPower {
            cells.append(ValueCellData(label: "BUYING POWER", value: self.formatCurrency(buyingPower)))
        }

        if let estimatedOrderCommission = orderDetails.estimatedOrderCommission {
            cells.append(ValueCellData(label: "BROKER FEE", value: self.formatCurrency(estimatedOrderCommission)))
        }

        if let estimatedTotalValue = orderDetails.estimatedTotalValue {
            cells.append(ValueCellData(label: "ESTIMATED COST", value: self.formatCurrency(estimatedTotalValue)))
        }

        return cells
    }

    private func formatCurrency(_ value: NSNumber) -> String {
        return NumberFormatter.formatCurrency(value, currencyCode: TradeItPresenter.DEFAULT_CURRENCY_CODE)
    }
}

// TODO: Add to YahooTradingUIFlow
protocol TradeItYahooTradingConfirmationViewControllerDelegate: class {
    //func tradeButtonWasTapped(_ tradeItTradingConfirmationViewController: TradeItYahooTradingConfirmationViewController)
}

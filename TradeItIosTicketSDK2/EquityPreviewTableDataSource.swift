import UIKit

class PreviewTableDataSource: NSObject, UITableViewDataSource {
    var isOrderPlaced: Bool {
        get {
            return self.factory.placeOrderResult != nil
        }
    }
    private var previewCellData: [PreviewCellData]
    private var factory: PreviewCellFactory
    private weak var delegate: PreviewMessageDelegate?

    init(delegate: PreviewMessageDelegate, factory: PreviewCellFactory) {
        self.delegate = delegate
        self.factory = factory
        self.previewCellData = factory.generateCellData()
    }

    func update(placeOrderResult: TradeItPlaceOrderResult) {
        self.factory.placeOrderResult = placeOrderResult
        self.previewCellData = factory.generateCellData()
    }

    func allAcknowledgementsAccepted() -> Bool {
        return previewCellData.flatMap { $0 as? MessageCellData }.filter { !$0.isValid() }.count == 0
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
            cell.populate(withCellData: messageCellData, andDelegate: delegate)
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
}

protocol PreviewCellFactory {
    var placeOrderResult: TradeItPlaceOrderResult? { get set }
    func generateCellData() -> [PreviewCellData]
}

class CryptoPreviewTableDataSource: PreviewCellFactory {
    private let linkedBrokerAccount: TradeItLinkedBrokerAccount
    private let orderCapabilities: TradeItInstrumentOrderCapabilities?
    private let previewOrderResult: TradeItCryptoPreviewTradeResult
    var placeOrderResult: TradeItPlaceOrderResult?
    private weak var delegate: PreviewMessageDelegate?

    init(
        previewMessageDelegate delegate: PreviewMessageDelegate,
        linkedBrokerAccount: TradeItLinkedBrokerAccount,
        previewOrderResult: TradeItCryptoPreviewTradeResult
    ) {
        self.delegate = delegate
        self.linkedBrokerAccount = linkedBrokerAccount
        self.previewOrderResult = previewOrderResult
        self.orderCapabilities = self.linkedBrokerAccount.orderCapabilities.filter { $0.instrument == "crypto" }.first
    }

    func generateCellData() -> [PreviewCellData] {
        guard let orderDetails = previewOrderResult.orderDetails
            else { return [] }

        var cells = [PreviewCellData]()

        cells += [
            ValueCellData(label: "Account", value: linkedBrokerAccount.getFormattedAccountName())
        ] as [PreviewCellData]

//        let orderDetailsPresenter = TradeItOrderDetailsPresenter(
//            orderDetails: orderDetails,
//            orderCapabilities: orderCapabilities
//        )
//
//        if let orderNumber = self.placeOrderResult?.orderNumber {
//            cells += [
//                ValueCellData(label: "Order #", value: orderNumber)
//                ] as [PreviewCellData]
//        }
//
//        cells += [
//            ValueCellData(label: "Action", value: orderDetailsPresenter.getOrderActionLabel()),
//            ValueCellData(label: "Symbol", value: orderDetails.orderSymbol),
//            ValueCellData(label: "Shares", value: NumberFormatter.formatQuantity(orderDetails.orderQuantity)),
//            ValueCellData(label: "Price", value: orderDetails.orderPrice),
//            ValueCellData(label: "Time in force", value: orderDetailsPresenter.getOrderExpirationLabel())
//            ] as [PreviewCellData]
//
//        if self.linkedBrokerAccount.userCanDisableMargin {
//            cells.append(ValueCellData(label: "Type", value: MarginPresenter.labelFor(value: orderDetailsPresenter.userDisabledMargin)))
//        }
//
//        if let estimatedOrderCommission = orderDetails.estimatedOrderCommission {
//            cells.append(ValueCellData(label: orderDetails.orderCommissionLabel, value: self.formatCurrency(estimatedOrderCommission)))
//        }

        if let estimatedTotalValue = orderDetails.estimatedTotalValue {
            let action = TradeItOrderAction(value: orderDetails.orderAction)
            let title = "Estimated \(TradeItOrderActionPresenter.SELL_ACTIONS.contains(action) ? "proceeds" : "cost")"
            cells.append(ValueCellData(label: title, value: formatCurrency(estimatedTotalValue)))
        }

        if self.placeOrderResult != nil {
            cells += generateMessageCellData()
        }

        return cells
    }

    private func generateMessageCellData() -> [PreviewCellData] {
        guard let messages = previewOrderResult.orderDetails?.warnings else { return [] }
        return messages.map(MessageCellData.init)
    }

    private func formatCurrency(_ value: NSNumber) -> String {
        return NumberFormatter.formatCurrency(value, currencyCode: self.linkedBrokerAccount.accountBaseCurrency)
    }
}

class EquityPreviewTableDataSource: PreviewCellFactory {
    private let linkedBrokerAccount: TradeItLinkedBrokerAccount
    private let orderCapabilities: TradeItInstrumentOrderCapabilities?
    private let previewOrderResult: TradeItPreviewOrderResult
    var placeOrderResult: TradeItPlaceOrderResult?
    private weak var delegate: PreviewMessageDelegate?

    init(
        previewMessageDelegate delegate: PreviewMessageDelegate,
        linkedBrokerAccount: TradeItLinkedBrokerAccount,
        previewOrderResult: TradeItPreviewOrderResult
    ) {
        self.delegate = delegate
        self.linkedBrokerAccount = linkedBrokerAccount
        self.previewOrderResult = previewOrderResult
        self.orderCapabilities = self.linkedBrokerAccount.orderCapabilities.filter { $0.instrument == "equities" }.first
    }

    func generateCellData() -> [PreviewCellData] {
        guard let orderDetails = previewOrderResult.orderDetails
            else { return [] }

        var cells = [PreviewCellData]()

        cells += [
            ValueCellData(label: "Account", value: linkedBrokerAccount.getFormattedAccountName())
        ] as [PreviewCellData]

        let orderDetailsPresenter = TradeItOrderDetailsPresenter(
            orderDetails: orderDetails,
            orderCapabilities: orderCapabilities
        )

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

        if self.placeOrderResult != nil {
            cells += generateMessageCellData()
        }

        return cells
    }

    // MARK: Private

    private func generateMessageCellData() -> [PreviewCellData] {
        guard let messages = previewOrderResult.orderDetails?.warnings else { return [] }
        return messages.map(MessageCellData.init)
    }

    private func formatCurrency(_ value: NSNumber) -> String {
        return NumberFormatter.formatCurrency(value, currencyCode: self.linkedBrokerAccount.accountBaseCurrency)
    }
}

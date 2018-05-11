class CryptoPreviewCellFactory: PreviewCellFactory {
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
        let orderDetails = previewOrderResult.orderDetails

        var cells = [PreviewCellData]()

        cells += [
            ValueCellData(label: "Account", value: linkedBrokerAccount.getFormattedAccountName())
        ] as [PreviewCellData]

        let orderDetailsPresenter = TradeItOrderDetailsPresenter(
            orderAction: orderDetails.orderAction,
            orderExpiration: orderDetails.orderExpiration,
            orderCapabilities: orderCapabilities
        )

        if let orderNumber = self.placeOrderResult?.orderNumber {
            cells += [
                ValueCellData(label: "Order #", value: orderNumber)
            ] as [PreviewCellData]
        }

        cells += [
            ValueCellData(label: "Action", value: orderDetailsPresenter.getOrderActionLabel()),
            ValueCellData(label: "Symbol", value: orderDetails.orderPair),
            ValueCellData(label: "Shares", value: NumberFormatter.formatQuantity(orderDetails.orderQuantity)),
            ValueCellData(label: "Price", value: NumberFormatter.formatCurrency(orderDetails.estimatedOrderValue ?? 0.0)), // TODO: Figure out optionality here
            ValueCellData(label: "Time in force", value: orderDetailsPresenter.getOrderExpirationLabel())
        ] as [PreviewCellData]

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
        guard let messages = previewOrderResult.orderDetails.warnings else { return [] }
        return messages.map(MessageCellData.init)
    }

    private func formatCurrency(_ value: NSNumber) -> String {
        return NumberFormatter.formatCurrency(value, currencyCode: self.linkedBrokerAccount.accountBaseCurrency)
    }
}

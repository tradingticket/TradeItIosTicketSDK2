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

import UIKit

class TradeItTransactionTableViewHeader: UITableViewCell {

    @IBOutlet weak var numberOfDaysHistoryLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func populate(numberOfDays: Int, filterType: TransactionFilterType) {
        if filterType != .ALL_TRANSACTIONS {
            self.numberOfDaysHistoryLabel.text = "\(filterType.rawValue) past \(numberOfDays) days"
        } else {
            self.numberOfDaysHistoryLabel.text = "Past \(numberOfDays) days"
        }
    }

}

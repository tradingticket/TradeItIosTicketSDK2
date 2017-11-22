import UIKit

class TradeItTransactionTableViewHeader: UITableViewCell {

    @IBOutlet weak var numberOfDaysHistoryLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func populate(numberOfDays: Int) {
        self.numberOfDaysHistoryLabel.text = "Past \(numberOfDays) days"
    }

}

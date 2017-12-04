import UIKit

class TradeItGroupOrderHeaderTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func populate(withOrderStatusDetailsPresenter orderStatusPresenter: TradeItOrderStatusDetailsPresenter) {
        self.textLabel?.text = orderStatusPresenter.getGroupOrderHeaderTitle()
    }

}

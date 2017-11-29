import UIKit

class TradeItGroupOrderHeaderTableViewCell: UITableViewCell {

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var detail: UILabel!


    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func populate(withOrderStatusDetailsPresenter orderStatusPresenter: TradeItOrderStatusDetailsPresenter) {
        self.contentView.backgroundColor = UIColor.tradeItlightGreyHeaderBackgroundColor
        title.text = orderStatusPresenter.getGroupOrderHeaderTitle().uppercased()
        if orderStatusPresenter.isCancelable() {
            detail.text = "Swipe to cancel"
        } else {
            detail.text = ""
        }
    }

}

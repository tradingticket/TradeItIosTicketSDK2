import UIKit

class TradeItOrderTableViewHeader: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func populate(title: String, isCancelable: Bool = false) {
        self.titleLabel?.text = title
        TradeItThemeConfigurator.configureTableHeader(header: self.contentView)
        if isCancelable {
            self.detailLabel?.text = "Swipe to cancel"
            self.detailLabel?.font = UIFont.systemFont(ofSize: 9)
        } else {
            self.detailLabel?.text = ""
        }
    }
    
}

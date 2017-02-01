import UIKit

class TradeItSelectionCellTableViewCell: UITableViewCell {
    override func awakeFromNib() {
        super.awakeFromNib()
        // TODO: color disclosure indicator chevron
    }

    func configure(selection: String, onTapped: () -> Void) {
        self.detailTextLabel?.text = selection
//        self.
    }
}

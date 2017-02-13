import UIKit

class TradeItSelectionDetailCellTableViewCell: UITableViewCell {
    @IBOutlet weak var detailButton: UIButton!
    @IBOutlet weak var detailLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // TODO: color disclosure indicator chevron
    }

    func configure(selection: String, detail: String) {
        self.detailButton.setTitle(selection, for: .normal)
        self.detailLabel.text = detail
    }
}

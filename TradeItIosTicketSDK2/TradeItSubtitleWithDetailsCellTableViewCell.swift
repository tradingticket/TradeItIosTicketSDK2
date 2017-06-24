import UIKit

class TradeItSubtitleWithDetailsCellTableViewCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var detailsLabel: UILabel!
    @IBOutlet weak var subtitleDetailsLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func configure(subtitleLabel: String?, detailsLabel: String?, subtitleDetailsLabel: String?, subtitleDetailsLabelColor: UIColor?) {
        self.titleLabel?.text = self.textLabel?.text
        self.textLabel?.text = nil

        self.subtitleLabel?.text = subtitleLabel
        self.detailsLabel?.text = detailsLabel
        self.subtitleDetailsLabel?.text = subtitleDetailsLabel
        self.subtitleDetailsLabel.textColor = subtitleDetailsLabelColor
    }
}

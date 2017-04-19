import UIKit

class TradeItSubtitleWithDetailsCellTableViewCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var detailsLabel: UILabel!
    @IBOutlet weak var subtitleDetailsLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configure(quotePresenter: TradeItQuotePresenter?) {
        self.titleLabel?.text = self.textLabel?.text
        self.textLabel?.text = nil
        if let quotePresenter = quotePresenter {
            self.subtitleLabel?.text = quotePresenter.getTimestampLabel()
            self.detailsLabel?.text = quotePresenter.getLastPriceLabel()
            self.subtitleDetailsLabel?.text = quotePresenter.getChangeLabel()
            self.subtitleDetailsLabel.textColor = quotePresenter.getChangeLabelColor()
        } else {
            self.subtitleLabel?.text = TradeItPresenter.MISSING_DATA_PLACEHOLDER
            self.detailsLabel?.text = TradeItPresenter.MISSING_DATA_PLACEHOLDER
            self.subtitleDetailsLabel?.text = ""
        }
    }

}

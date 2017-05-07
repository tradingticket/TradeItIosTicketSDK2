import UIKit

// TODO: If this is specific to displaying only quotes, it should have a less generic name
//       OR it should be subclassed to a more specific quote use case.
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
            self.subtitleLabel?.text = quotePresenter.getTimestampLabelText()
            self.detailsLabel?.text = quotePresenter.getLastPriceLabelText()
            self.subtitleDetailsLabel?.text = quotePresenter.getChangeLabelText()
            self.subtitleDetailsLabel.textColor = quotePresenter.getChangeLabelColor()
        } else {
            self.subtitleLabel?.text = TradeItPresenter.MISSING_DATA_PLACEHOLDER
            self.detailsLabel?.text = TradeItPresenter.MISSING_DATA_PLACEHOLDER
            self.subtitleDetailsLabel?.text = ""
        }
    }

}

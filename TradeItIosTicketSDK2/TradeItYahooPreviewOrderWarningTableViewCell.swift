import UIKit

class TradeItYahooPreviewOrderWarningTableViewCell: UITableViewCell {

    @IBOutlet weak var warning: UILabel!
    
    func populate(withWarning warning: String) {
        self.warning.text = warning
    }

}

import UIKit

class TradeItPreviewOrderAcknowledgementTableViewCell: UITableViewCell {
    @IBOutlet weak var acknowledgementSwitch: UISwitch!
    @IBOutlet weak var acknowledgement: UILabel!

    func populate(withAcknowledgement acknowledgement: String) {
        self.acknowledgement.text = acknowledgement
    }
}

import UIKit
import BEMCheckBox

internal protocol PreviewMessageDelegate: class {
    func acknowledgementWasChanged()
    func launchLink(url: String)
}

class TradeItPreviewMessageTableViewCell: UITableViewCell {
    @IBOutlet weak var message: UILabel!
    @IBOutlet weak var links: UIStackView!
    @IBOutlet weak var acknowledgementContainer: UIView!
    @IBOutlet weak var acknowledgementCheckBox: BEMCheckBox!
    @IBOutlet weak var stackView: UIStackView!

    var cellData: MessageCellData?
    internal weak var delegate: PreviewMessageDelegate?

    func populate(withCellData cellData: MessageCellData, andDelegate delegate: PreviewMessageDelegate?) {
        self.cellData = cellData
        self.message.text = cellData.message.message
        if cellData.message.requiresAcknowledgement {
            self.acknowledgementCheckBox.setOn(cellData.isAcknowledged, animated: false)
            self.acknowledgementContainer.isHidden = false
        } else {
            self.acknowledgementContainer.isHidden = true
        }

        self.links.arrangedSubviews.forEach { $0.removeFromSuperview() }
        cellData.message.links.forEach { link in
            let linkButton = LinkButton()
            let title = link.label
            linkButton.setTitle(title + " ›", for: .normal)
            linkButton.url = link.url
            linkButton.addTarget(self, action: #selector(didTapLink), for: .touchUpInside)
            TradeItThemeConfigurator.configurePreviewMessageCellLink(link: linkButton)
            self.links.addArrangedSubview(linkButton)
        }
        self.delegate = delegate
        self.stackView.layoutIfNeeded()
    }

    @objc func didTapLink(_ button: LinkButton) {
        guard let url = button.url else { return }
        self.delegate?.launchLink(url: url)
    }

    @IBAction func didTap(_ checkBox: BEMCheckBox) {
        self.cellData?.isAcknowledged = checkBox.on
        self.delegate?.acknowledgementWasChanged()
    }
}

internal class LinkButton: UIButton {
    var url: String?
}

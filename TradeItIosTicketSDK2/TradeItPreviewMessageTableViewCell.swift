import UIKit
import BEMCheckBox

internal protocol PreviewMessageDelegate: class {
    func acknowledgementWasChanged()
    func launchLink(url: String)
}

class TradeItPreviewMessageTableViewCell: UITableViewCell, BEMCheckBoxDelegate {
    @IBOutlet weak var message: UILabel!
    @IBOutlet weak var links: UIStackView!

    var cellData: MessageCellData?
    var checkbox: BEMCheckBox?
    internal weak var delegate: PreviewMessageDelegate?

    override func awakeFromNib() {
        TradeItThemeConfigurator.configurePreviewMessageCell(cell: self)
    }

    func populate(withCellData cellData: MessageCellData, andDelegate delegate: PreviewMessageDelegate) {
        self.cellData = cellData
        self.message.text = cellData.message.message
        if cellData.message.requiresAcknowledgement {
            self.checkbox = BEMCheckBox(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
            self.checkbox?.on = cellData.isAcknowledged
            self.checkbox?.delegate = self
        } else {
            self.checkbox = nil
        }
        self.accessoryView?.heightAnchor.constraint(equalToConstant: 20)
        self.accessoryView = self.checkbox

        self.links.arrangedSubviews.forEach { $0.removeFromSuperview() }
        cellData.message.links.forEach { link in
            let linkButton = LinkButton()
            let title = link.label ?? "View link"
            linkButton.setTitle(title + " >", for: .normal)
            linkButton.url = link.url
            linkButton.addTarget(self, action: #selector(didTapLink), for: .touchUpInside)
            TradeItThemeConfigurator.configurePreviewMessageCellLink(link: linkButton)
            self.links.addArrangedSubview(linkButton)
        }
        self.delegate = delegate
    }

    @objc func didTapLink(_ button: LinkButton) {
        guard let url = button.url else { return }
        self.delegate?.launchLink(url: url)
    }

    func didTap(_ checkBox: BEMCheckBox) {
        self.cellData?.isAcknowledged = checkBox.on
        self.delegate?.acknowledgementWasChanged()
    }
}

internal class LinkButton: UIButton {
    var url: String?
}

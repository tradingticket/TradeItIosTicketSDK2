import UIKit

class TradeItSelectionDetailCellTableViewCell: UITableViewCell {
    @IBOutlet weak var detailPrimaryLabel: UILabel!
    @IBOutlet weak var detailSecondaryLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // TODO: color disclosure indicator chevron
        self.accessoryType = .none
        self.accessoryView = YahooDisclosureIndicator()

    }

    func configure(detailPrimaryText: String?, detailSecondaryText: String?) {
        self.detailPrimaryLabel.text = detailPrimaryText
        self.detailSecondaryLabel.text = detailSecondaryText


        //let image = imageView.image?.withRenderingMode(.alwaysTemplate)
        //imageView.image = image
        //imageView.tintColor = TradeItSDK.theme.interactivePrimaryColor
    }
}

private class YahooDisclosureIndicator: UIView {
    var color = UIColor.tradeItCoolBlueColor

    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }

        let x = self.bounds.maxX - 3
        let y = self.bounds.midY
        let R = CGFloat(4.5)

        context.move(to: CGPoint(x: x - R, y: y - R))
        context.addLine(to: CGPoint(x: x, y: y))
        context.addLine(to: CGPoint(x: x - R, y: y + R))
        context.setLineCap(CGLineCap.square)
        context.setLineJoin(CGLineJoin.miter)
        context.setLineWidth(2)
        color.setStroke()
        context.strokePath()
    }
    
}

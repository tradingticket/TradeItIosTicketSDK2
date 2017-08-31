import UIKit

internal class DisclosureIndicator: UIView {
    var color = UIButton().tintColor ?? UIColor.gray

    init() {
        super.init(frame: CGRect(x: 0, y: 0, width: 15.0, height: 15.0))
        self.isOpaque = false
        self.backgroundColor = .clear
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

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

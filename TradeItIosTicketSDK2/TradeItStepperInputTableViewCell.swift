import UIKit

class TradeItStepperInputTableViewCell: UITableViewCell {
    @IBOutlet weak var textField: TradeItNumberField!
    @IBOutlet weak var decrementButton: UIButton!
    @IBOutlet weak var incrementButton: UIButton!

    var onValueUpdated: ((_ newValue: NSDecimalNumber?) -> Void)?

    override func awakeFromNib() {
        self.textField.padding = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
        self.theme(button: self.decrementButton, roundingCorners: [.topLeft, .bottomLeft])
        self.theme(button: self.incrementButton, roundingCorners: [.topRight, .bottomRight])
    }

    func configure(initialValue: NSDecimalNumber?,
                   placeholderText: String,
                   onValueUpdated: @escaping (_ newValue: NSDecimalNumber?) -> Void) {
        self.onValueUpdated = onValueUpdated
        self.textField.placeholder = placeholderText

        if let initialValue = initialValue {
            self.textField.text = "\(initialValue)"
        } else {
            self.textField.text = nil
        }
    }

    // MARK: IBActions

    @IBAction func textFieldDidChange(_ sender: TradeItNumberField) {
        let numericValue = NSDecimalNumber.init(string: sender.text)

        if numericValue == NSDecimalNumber.notANumber {
            self.onValueUpdated?(nil)
        } else {
            self.onValueUpdated?(numericValue)
        }
    }

    @IBAction func incrementButtonTapped(_ sender: UIButton) {
        let numericValue = NSDecimalNumber.init(string: self.textField.text)

        if numericValue != NSDecimalNumber.notANumber {
            let newValue = numericValue.adding(0.0001)
            self.textField.text = newValue.stringValue
            self.onValueUpdated?(numericValue)
        }
    }

    @IBAction func decrementButtonTapped(_ sender: UIButton) {
        let numericValue = NSDecimalNumber.init(string: self.textField.text)

        if numericValue != NSDecimalNumber.notANumber {
            let newValue = numericValue.subtracting(0.0001)
            self.textField.text = newValue.stringValue
            self.onValueUpdated?(numericValue)
        }
    }

    private func theme(button: UIButton, roundingCorners: UIRectCorner) {
        let path = UIBezierPath(
            roundedRect: button.bounds,
            byRoundingCorners: roundingCorners,
            cornerRadii: CGSize(width: 5, height:  5)
        )

        let maskLayer = CAShapeLayer()
        maskLayer.path = path.cgPath

        button.layer.mask = maskLayer
    }
}

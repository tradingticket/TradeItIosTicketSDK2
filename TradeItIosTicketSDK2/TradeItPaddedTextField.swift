import UIKit

class TradeItPaddedTextField: UITextField {
    var padding: UIEdgeInsets?

    // MARK: UIView

    override func textRect(forBounds bounds: CGRect) -> CGRect {
        if let padding = self.padding {
            return bounds.inset(by: padding)
        } else {
            return super.textRect(forBounds: bounds)
        }
    }

    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        if let padding = self.padding {
            return bounds.inset(by: padding)
        } else {
            return super.placeholderRect(forBounds: bounds)
        }
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        if let padding = self.padding {
            return bounds.inset(by: padding)
        } else {
            return super.editingRect(forBounds: bounds)
        }
    }
}

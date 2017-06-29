import UIKit

class TradeItNumberField: TradeItPaddedTextField, UITextFieldDelegate {
    static let invalidCharacters = CharacterSet.decimalDigits.union(CharacterSet(charactersIn: ",.")).inverted
    static let disabledActions = [
        #selector(copy(_:)),
        #selector(paste(_:)),
        #selector(select(_:)),
        #selector(selectAll(_:)),
        #selector(cut(_:))
    ]

    var maxDecimalPlaces = 4

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.delegate = self
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.delegate = self
    }

    // MARK: UITextField

    override public func canPerformAction(
        _ action: Selector,
        withSender sender: Any?
    ) -> Bool {
        if TradeItNumberField.disabledActions.contains(action) {
            return false
        }

        return super.canPerformAction(action, withSender: sender)
    }

    // MARK: UITextFieldDelegate

    func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        if string == "" { return true }

        let currentText: NSString = textField.text as NSString? ?? ""
        let resultText = currentText.replacingCharacters(in: range, with: string)


        let hasOnlyValidCharacters = resultText.rangeOfCharacter(from: TradeItNumberField.invalidCharacters) == nil
        let hasOnlyOneDecimalPoint = resultText.components(separatedBy: CharacterSet(charactersIn: ",.")).count <= 2

        let components = resultText.components(separatedBy: CharacterSet(charactersIn: ",."))
        let decimalPlaces = components.last?.lengthOfBytes(using: .utf8) ?? 0
        let hasValidNumberOfDecimalPlaces = components.count <= 1 || decimalPlaces <= maxDecimalPlaces

        return hasOnlyValidCharacters && hasOnlyOneDecimalPoint && hasValidNumberOfDecimalPlaces
    }
}

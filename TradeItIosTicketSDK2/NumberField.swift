import UIKit

class NumberField: UITextField, UITextFieldDelegate {
    static let invalidCharacters = CharacterSet.decimalDigits.union(CharacterSet(charactersIn: ",.")).inverted
    static let disabledActions = [
        #selector(copy(_:)),
        #selector(paste(_:)),
        #selector(select(_:)),
        #selector(selectAll(_:)),
        #selector(cut(_:))
    ]

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.delegate = self
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.delegate = self
    }

    override public func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if NumberField.disabledActions.contains(action) {
            return false
        }

        return super.canPerformAction(action, withSender: sender)
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return string.rangeOfCharacter(from: NumberField.invalidCharacters) == nil
    }
}

import UIKit

class TradeItNumericInputCell: UITableViewCell {
    @IBOutlet weak var textField: TradeItNumberField!
    
    var onValueUpdated: ((_ newValue: NSDecimalNumber?) -> Void)?
    
    override func awakeFromNib() {
        self.textField.padding = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
        self.addDoneButtonOnKeyboard()
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
    
    func addDoneButtonOnKeyboard(){
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
        doneToolbar.barStyle = UIBarStyle.default
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        
        let done: UIBarButtonItem  = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.done, target: self, action: #selector(self.doneButtonAction))
        
        var items = [UIBarButtonItem]()
        items.append(flexSpace)
        items.append(done)
        
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        
        textField.inputAccessoryView = doneToolbar
    }
    
    func doneButtonAction(){
        textField.resignFirstResponder()
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
}

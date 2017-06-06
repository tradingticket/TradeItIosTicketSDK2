import UIKit

class TradeItDismissableKeyboardTableView: UITableView {
    // MARK: UIResponder
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
}

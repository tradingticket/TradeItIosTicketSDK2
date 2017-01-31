import UIKit

class TradeItYahooTradingTicketTableView: UITableView {
    // MARK: UIResponder
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.endEditing(true)
    }
}

import UIKit
import TradeItIosEmsApi

class TradeItPortfolioErrorHandlerManager: NSObject {

    private var _otherTablesView: UIView?
    var otherTablesView: UIView? {
        get {
            return _otherTablesView
        }
        
        set(otherTablesView) {
            if let otherTablesView = otherTablesView {
                otherTablesView.hidden = false
                _otherTablesView = otherTablesView
            }
        }
    }
    
    private var _errorHandlingView: TradeItPortfolioErrorHandlingView?
    var errorHandlingView: TradeItPortfolioErrorHandlingView? {
        get {
            return _errorHandlingView
        }
        
        set(errorHandlingView) {
            if let errorHandlingView = errorHandlingView {
                errorHandlingView.hidden = true
                _errorHandlingView = errorHandlingView
            }
        }
    }
    
    func showErrorHandlingView(withLinkedBrokerInError linkedBrokerInError: TradeItLinkedBroker) {
        self.otherTablesView?.hidden = true
        self.errorHandlingView?.hidden = false
        self.errorHandlingView?.populateWithLinkedBrokerError(linkedBrokerInError)
    }
    
    func showOtherTablesView() {
        self.errorHandlingView?.hidden = true
        self.otherTablesView?.hidden = false
    }

}

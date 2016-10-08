import UIKit
import TradeItIosEmsApi

class TradeItPortfolioErrorHandlingViewManager: NSObject {

    private var _accountInfoContainerView: UIView?
    var accountInfoContainerView: UIView? {
        get {
            return _accountInfoContainerView
        }
        
        set(accountInfoContainerView) {
            if let accountInfoContainerView = accountInfoContainerView {
                accountInfoContainerView.hidden = false
                _accountInfoContainerView = accountInfoContainerView
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
        self.accountInfoContainerView?.hidden = true
        self.errorHandlingView?.hidden = false
        self.errorHandlingView?.populateWithLinkedBrokerError(linkedBrokerInError)
    }
    
    func showAccountInfoContainerView() {
        self.errorHandlingView?.hidden = true
        self.accountInfoContainerView?.hidden = false
    }
}

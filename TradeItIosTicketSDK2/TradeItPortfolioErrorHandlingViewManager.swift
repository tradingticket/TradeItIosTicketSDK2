import UIKit

class TradeItPortfolioErrorHandlingViewManager: NSObject {

    fileprivate var _accountInfoContainerView: UIView?
    var accountInfoContainerView: UIView? {
        get {
            return _accountInfoContainerView
        }
        
        set(accountInfoContainerView) {
            if let accountInfoContainerView = accountInfoContainerView {
                accountInfoContainerView.isHidden = false
                _accountInfoContainerView = accountInfoContainerView
            }
        }
    }
    
    fileprivate var _errorHandlingView: TradeItPortfolioErrorHandlingView?
    var errorHandlingView: TradeItPortfolioErrorHandlingView? {
        get {
            return _errorHandlingView
        }
        
        set(errorHandlingView) {
            if let errorHandlingView = errorHandlingView {
                errorHandlingView.isHidden = true
                _errorHandlingView = errorHandlingView
            }
        }
    }
    
    func showErrorHandlingView(withLinkedBrokerInError linkedBrokerInError: TradeItLinkedBroker) {
        self.accountInfoContainerView?.isHidden = true
        self.errorHandlingView?.isHidden = false
        self.errorHandlingView?.populateWithLinkedBrokerError(linkedBrokerInError)
    }
    
    func showAccountInfoContainerView() {
        self.errorHandlingView?.isHidden = true
        self.accountInfoContainerView?.isHidden = false
    }
}

import UIKit
import TradeItIosEmsApi

// TODO: This should be a provider that returns instances of UIAlertController
class TradeItAlert {
    
    func showTradeItErrorResultAlert(onViewController viewController: UIViewController,
                                                      errorResult: TradeItErrorResult,
                                                      onAlertDismissed: () -> Void = {}) {
        var title = ""
        if let shortMessage = errorResult.shortMessage {
            title = shortMessage
        }
        var message = ""
        if let longMessages = errorResult.longMessages {
            message = (longMessages as! [String]).joinWithSeparator(" ")
        }
        
        let alertController = UIAlertController(title: title,
                                                message: message,
                                                preferredStyle: UIAlertControllerStyle.Alert)
        
        let okAction = UIAlertAction(title: "OK",
                                     style: UIAlertActionStyle.Default) { (result : UIAlertAction) -> Void in
                                        onAlertDismissed()
        }
        
        alertController.addAction(okAction)
        viewController.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func showErrorAlert(onViewController viewController: UIViewController,
                                         title: String,
                                         message: String,
                                         actionTitle: String = "OK",
                                         onAlertDismissed: () -> Void = {}) {
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: UIAlertControllerStyle.Alert)
        
        let action = UIAlertAction(title: actionTitle,
                                   style: UIAlertActionStyle.Default) { (result : UIAlertAction) -> Void in
            onAlertDismissed()
        }

        alert.addAction(action)
        viewController.presentViewController(alert, animated: true, completion: nil)
    }

    func showValidationAlert(onViewController viewController: UIViewController,
                                              title: String,
                                              message: String,
                                              actionTitle: String = "OK",
                                              onValidate: () -> Void = {},
                                              onCancel: () -> Void) {
        
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: UIAlertControllerStyle.Alert)

        let actionValidate = UIAlertAction(title: actionTitle,
                                           style: UIAlertActionStyle.Default) { (result : UIAlertAction) -> Void in
                                            onValidate()
        }

        let actionCancel = UIAlertAction(title: "Cancel",
                                         style: UIAlertActionStyle.Default) { (result : UIAlertAction) -> Void in
                                            onCancel()
        }

        alert.addAction(actionCancel)
        alert.addAction(actionValidate)

        viewController.presentViewController(alert, animated: true, completion: nil)
    }
}

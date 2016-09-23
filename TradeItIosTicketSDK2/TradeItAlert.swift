import UIKit
import TradeItIosEmsApi

class TradeItAlert {
    
    func showTradeItErrorResultAlert(onController controller: UIViewController, withError tradeItErrorResult: TradeItErrorResult, withCompletion completion: () -> Void = {}) {
        var title = ""
        if let shortMessage = tradeItErrorResult.shortMessage {
            title = shortMessage
        }
        var message = ""
        if let longMessages = tradeItErrorResult.longMessages {
            message = (longMessages as! [String]).joinWithSeparator(" ")
        }
        
        let alertController = UIAlertController(title: title,
                                                message: message,
                                                preferredStyle: UIAlertControllerStyle.Alert)
        
        let okAction = UIAlertAction(title: "OK",
                                     style: UIAlertActionStyle.Default) { (result : UIAlertAction) -> Void in
                                        completion()
        }
        
        alertController.addAction(okAction)
        controller.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func showErrorAlert(onController controller: UIViewController, withTitle title: String, withMessage message: String, withActionTitle actionTitle: String = "Ok", withCompletion completion: () -> Void = {}) {
        let alert = UIAlertController(title: title,
        message: message,
        preferredStyle: UIAlertControllerStyle.Alert)
        
        let action = UIAlertAction(title: actionTitle, style: UIAlertActionStyle.Default) { (result : UIAlertAction) -> Void in
            completion()
        }

        alert.addAction(action)
        controller.presentViewController(alert, animated: true, completion: completion)
    }
    
    func showValidationAlert(onController controller: UIViewController, withTitle title: String, withMessage message: String, withActionOkTitle actionTitle: String = "Ok", onValidate: () -> Void = {}, onCancel: () -> Void, withCompletion completion: () -> Void = {}) {

            let alert = UIAlertController(title: title,
                                          message: message,
                                          preferredStyle: UIAlertControllerStyle.Alert)
            
            let actionValidate = UIAlertAction(title: actionTitle, style: UIAlertActionStyle.Default) { (result : UIAlertAction) -> Void in
                onValidate()
            }
        
            let actionCancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default) { (result : UIAlertAction) -> Void in
                onCancel()
            }
            alert.addAction(actionCancel)
            alert.addAction(actionValidate)
        
            controller.presentViewController(alert, animated: true, completion: completion)
    }
}

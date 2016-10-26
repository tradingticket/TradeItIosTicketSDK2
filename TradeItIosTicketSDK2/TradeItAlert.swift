import UIKit

// TODO: This should be a provider that returns instances of UIAlertController
class TradeItAlert {
    
    func showTradeItErrorResultAlert(onViewController viewController: UIViewController,
                                                      errorResult: TradeItErrorResult,
                                                      onAlertDismissed: @escaping () -> Void = {}) {
        var title = ""
        if let shortMessage = errorResult.shortMessage {
            title = shortMessage
        }
        var message = ""
        if let longMessages = errorResult.longMessages {
            message = (longMessages as! [String]).joined(separator: " ")
        }
        
        let alertController = UIAlertController(title: title,
                                                message: message,
                                                preferredStyle: UIAlertControllerStyle.alert)
        
        let okAction = UIAlertAction(title: "OK",
                                     style: UIAlertActionStyle.default) { (result : UIAlertAction) -> Void in
                                        onAlertDismissed()
        }
        
        alertController.addAction(okAction)
        viewController.present(alertController, animated: true, completion: nil)
    }
    
    func showErrorAlert(onViewController viewController: UIViewController,
                                         title: String,
                                         message: String,
                                         actionTitle: String = "OK",
                                         onAlertDismissed: @escaping () -> Void = {}) {
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: UIAlertControllerStyle.alert)
        
        let action = UIAlertAction(title: actionTitle,
                                   style: UIAlertActionStyle.default) { (result : UIAlertAction) -> Void in
            onAlertDismissed()
        }

        alert.addAction(action)
        viewController.present(alert, animated: true, completion: nil)
    }

    func showValidationAlert(onViewController viewController: UIViewController,
                                              title: String,
                                              message: String,
                                              actionTitle: String = "OK",
                                              onValidate: @escaping () -> Void = {},
                                              onCancel: @escaping () -> Void) {
        
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: UIAlertControllerStyle.alert)

        let actionValidate = UIAlertAction(title: actionTitle,
                                           style: UIAlertActionStyle.default) { (result : UIAlertAction) -> Void in
                                            onValidate()
        }

        let actionCancel = UIAlertAction(title: "Cancel",
                                         style: UIAlertActionStyle.default) { (result : UIAlertAction) -> Void in
                                            onCancel()
        }

        alert.addAction(actionCancel)
        alert.addAction(actionValidate)

        viewController.present(alert, animated: true, completion: nil)
    }

    func show(securityQuestion: TradeItSecurityQuestionResult,
                onViewController viewController: UIViewController,
                       onAnswerSecurityQuestion: @escaping (_ withAnswer: String) -> Void,
                       onCancelSecurityQuestion: @escaping () -> Void) {
        let alert = UIAlertController(
            title: "Security Question",
            message: securityQuestion.securityQuestion,
            preferredStyle: .alert
        )

        alert.addTextField(configurationHandler: nil)

        let submitAction = UIAlertAction(title: "Submit", style: .default, handler: { action in
            let textField = alert.textFields![0] as UITextField
            onAnswerSecurityQuestion(textField.text!)
        })

        alert.addAction(submitAction)

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
            onCancelSecurityQuestion()
        })

        alert.addAction(cancelAction)

        viewController.present(alert, animated: true, completion: nil)
    }
}

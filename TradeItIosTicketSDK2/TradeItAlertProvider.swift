import UIKit

class TradeItAlertProvider {
    static func provideSimpleAlert(alertTitle alertTitle: String,
                                        alertMessage: String,
                                        alertActionTitle: String) -> UIAlertController {
        let alertController = UIAlertController(title: alertTitle,
                                                message: alertMessage,
                                                preferredStyle: UIAlertControllerStyle.Alert)
        
        let alertAction = UIAlertAction(title: alertActionTitle,
                                        style: UIAlertActionStyle.Default) { (result : UIAlertAction) -> Void in }
    
        alertController.addAction(alertAction)
        
        return alertController
    }

    static func provideAlertWithAction(alertTitle alertTitle: String,
                                            alertMessage: String,
                                            alertActionTitle: String,
                                            onAlertActionTapped: () -> Void,
                                            onCanceledActionTapped: () -> Void) -> UIAlertController {
        let alertController = UIAlertController(title: alertTitle,
                                                message: alertMessage,
                                                preferredStyle: UIAlertControllerStyle.Alert)

        let cancelAction = UIAlertAction(title: "Cancel",
                                         style: UIAlertActionStyle.Default) { (result : UIAlertAction) -> Void in
                                                    onCanceledActionTapped()
        }

        let alertAction = UIAlertAction(title: alertActionTitle,
                                        style: UIAlertActionStyle.Default) { (result : UIAlertAction) -> Void in
                                            onAlertActionTapped()
        }

        alertController.addAction(cancelAction)
        alertController.addAction(alertAction)
        
        return alertController
    }

    static func provideSecurityQuestionAlertWith(alertTitle alertTitle: String,
                                                            alertMessage: String,
                                                            alertActionTitle: String,
                                                            onAnswerSecurityQuestion: (withAnswer: String) -> Void,
                                                            onCancelSecurityQuestion: () -> Void) -> UIAlertController {
        let alertController = UIAlertController(title: alertTitle,
                                                message: alertMessage,
                                                preferredStyle: UIAlertControllerStyle.Alert)
        
        alertController.addTextFieldWithConfigurationHandler(nil)

        let submitAction = UIAlertAction(title: "Submit", style: .Default, handler: { (action) -> Void in
            let textField = alertController.textFields![0] as UITextField
            onAnswerSecurityQuestion(withAnswer: textField.text!)
        })

        let cancelAction = UIAlertAction(title: "Cancel",
                                        style: UIAlertActionStyle.Default) { (result : UIAlertAction) -> Void in
                                            onCancelSecurityQuestion()
        }

        alertController.addAction(cancelAction)
        alertController.addAction(submitAction)

        return alertController
    }
}

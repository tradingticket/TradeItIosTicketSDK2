import UIKit

// TODO: Make static methods instance methods so TradeItAlertProvider can be injected for tests
class TradeItAlertProvider {
    static func provideAlert(alertTitle alertTitle: String,
                                        alertMessage: String,
                                        alertActionTitle: String,
                                        onAlertActionTapped: () -> Void,
                                        onCanceledActionTapped: (() -> Void)? = nil) -> UIAlertController {
        let alertController = UIAlertController(title: alertTitle,
                                                message: alertMessage,
                                                preferredStyle: UIAlertControllerStyle.Alert)

        if let onCanceledActionTapped = onCanceledActionTapped {
            let cancelAction = UIAlertAction(
                title: "Cancel",
                style: UIAlertActionStyle.Default) { action in
                    onCanceledActionTapped()
            }

            alertController.addAction(cancelAction)
        }

        let alertAction = UIAlertAction(
            title: alertActionTitle,
            style: UIAlertActionStyle.Default) { action in
                onAlertActionTapped()
            }

        alertController.addAction(alertAction)

        return alertController
    }

    static func provideSecurityQuestionAlertWith(alertTitle alertTitle: String,
                                                            alertMessage: String,
                                                            multipleOptions: [String],
                                                            alertActionTitle: String,
                                                            onAnswerSecurityQuestion: (withAnswer: String) -> Void,
                                                            onCancelSecurityQuestion: () -> Void) -> UIAlertController {
        let alertController = UIAlertController(title: alertTitle,
                                                message: alertMessage,
                                                preferredStyle: UIAlertControllerStyle.Alert)

        let cancelAction = UIAlertAction(
            title: "Cancel",
            style: UIAlertActionStyle.Default) { action in
                onCancelSecurityQuestion()
        }
        
        alertController.addAction(cancelAction)
        
        if multipleOptions.count > 0 {
            for option in multipleOptions {
                let optionAction = UIAlertAction(title: option, style: .Default, handler: { action in
                    onAnswerSecurityQuestion(withAnswer: option)
                })
                alertController.addAction(optionAction)
            }
        } else {
            alertController.addTextFieldWithConfigurationHandler(nil)
            let submitAction = UIAlertAction(title: "Submit", style: .Default, handler: { action in
                let textField = alertController.textFields![0] as UITextField
                onAnswerSecurityQuestion(withAnswer: textField.text!)
            })
            alertController.addAction(submitAction)
        }
        

        
        

        return alertController
    }
}

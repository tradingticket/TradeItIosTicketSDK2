import UIKit

// TODO: Make static methods instance methods so TradeItAlertProvider can be injected for tests
class TradeItAlertProvider {
    static func provideAlert(
        alertTitle: String,
        alertMessage: String,
        alertActionTitle: String,
        onAlertActionTapped: @escaping () -> Void,
        showCancelAction: Bool = false,
        onCanceledActionTapped: (() -> Void)? = nil
    ) -> UIAlertController {
        let alertController = UIAlertController(
            title: alertTitle,
            message: alertMessage,
            preferredStyle: UIAlertControllerStyle.alert
        )

        if showCancelAction, let onCanceledActionTapped = onCanceledActionTapped {
            let cancelAction = UIAlertAction(
                title: "Cancel",
                style: UIAlertActionStyle.default) { action in
                    onCanceledActionTapped()
            }

            alertController.addAction(cancelAction)
        }

        let alertAction = UIAlertAction(
            title: alertActionTitle,
            style: UIAlertActionStyle.default
        ) { action in
                onAlertActionTapped()
            }

        alertController.addAction(alertAction)

        return alertController
    }

    static func provideSecurityQuestionAlertWith(
        alertTitle: String,
        alertMessage: String,
        multipleOptions: [String],
        alertActionTitle: String,
        onAnswerSecurityQuestion: @escaping (_ withAnswer: String) -> Void,
        onCancelSecurityQuestion: @escaping () -> Void
    ) -> UIAlertController {
        let alertController = UIAlertController(
            title: alertTitle,
            message: alertMessage,
            preferredStyle: UIAlertControllerStyle.alert
        )

        let cancelAction = UIAlertAction(
            title: "Cancel",
            style: UIAlertActionStyle.default
        ) { action in
                onCancelSecurityQuestion()
        }
        
        alertController.addAction(cancelAction)
        
        if multipleOptions.count > 0 {
            for option in multipleOptions {
                let optionAction = UIAlertAction(
                    title: option,
                    style: .default,
                    handler: { action in
                        onAnswerSecurityQuestion(option)
                    }
                )
                alertController.addAction(optionAction)
            }
        } else {
            alertController.addTextField(configurationHandler: { textField in
                textField.isSecureTextEntry = true
            })
            let submitAction = UIAlertAction(
                title: "Submit",
                style: .default,
                handler: { action in
                    let textField = alertController.textFields![0] as UITextField
                    onAnswerSecurityQuestion(textField.text!)
                }
            )
            alertController.addAction(submitAction)
        }

        return alertController
    }
}

import UIKit

@objc public class TradeItAlertManager: NSObject {
    var linkedBrokerManager = TradeItLauncher.linkedBrokerManager
    var linkBrokerUIFlow = TradeItLinkBrokerUIFlow(linkedBrokerManager: TradeItLauncher.linkedBrokerManager)

    public func showError(error: TradeItErrorResult,
                          onViewController viewController: UIViewController,
                          onFinished: () -> Void = {}) {
        let title = error.shortMessage ?? ""
        let messages = (error.longMessages as? [String]) ?? []
        let message = messages.joinWithSeparator(". ")
        let actionTitle = "OK"

        self.showAlert(onViewController: viewController,
                              withTitle: title,
                            withMessage: message,
                        withActionTitle: actionTitle,
                    onAlertActionTapped: onFinished)
    }

    public func showRelinkError(error: TradeItErrorResult,
                                withLinkedBroker linkedBroker: TradeItLinkedBroker,
                                onViewController viewController: UIViewController,
                                onFinished: () -> Void) {
        let onAlertActionRelinkAccount: () -> Void = {
            self.linkBrokerUIFlow.presentRelinkBrokerFlow(
                inViewController: viewController,
                linkedBroker: linkedBroker,
                onLinked: { presentedNavController, linkedBroker in
                    presentedNavController.dismissViewControllerAnimated(true, completion: nil)
                    linkedBroker.refreshAccountBalances(onFinished: onFinished)
                },
                onFlowAborted: { _ in onFinished() }
            )
        }

        switch error.errorCode() {
        case .BROKER_AUTHENTICATION_ERROR?:
            self.showAlert(
                onViewController: viewController,
                withTitle: "Update Login",
                withMessage: "There seems to be a problem connecting with your \(linkedBroker.linkedLogin.broker) account. Please update your login information.",
                withActionTitle: "Update",
                onAlertActionTapped: onAlertActionRelinkAccount,
                onCancelActionTapped: onFinished)
        case .OAUTH_ERROR?:
            self.showAlert(
                onViewController: viewController,
                withTitle: "Relink \(linkedBroker.linkedLogin.broker) Accounts",
                withMessage: "For your security, we automatically unlink any accounts that have not been used in the past 30 days. Please relink your accounts.",
                withActionTitle: "Update",
                onAlertActionTapped: onAlertActionRelinkAccount,
                onCancelActionTapped: onFinished)
        default:
            self.showError(error,
                onViewController: viewController,
                      onFinished: onFinished)
        }
    }

    public func promptUserToAnswerSecurityQuestion(securityQuestion: TradeItSecurityQuestionResult,
                                     onViewController viewController: UIViewController,
                                     onAnswerSecurityQuestion: (withAnswer: String) -> Void,
                                     onCancelSecurityQuestion: () -> Void) {
        let alertController = TradeItAlertProvider.provideSecurityQuestionAlertWith(
            alertTitle: "Security Question",
            alertMessage: securityQuestion.securityQuestion ?? "No security question provided.",
            multipleOptions: securityQuestion.securityQuestionOptions ?? [],
            alertActionTitle: "Submit",
            onAnswerSecurityQuestion: onAnswerSecurityQuestion,
            onCancelSecurityQuestion: onCancelSecurityQuestion)
        viewController.presentViewController(alertController, animated: true, completion: nil)
    }

    public func showAlert(onViewController viewController: UIViewController,
                          withTitle title: String,
                          withMessage message: String,
                          withActionTitle actionTitle: String,
                          onAlertActionTapped: () -> Void = {},
                          onCancelActionTapped: (() -> Void)? = nil) {
        let alertController = TradeItAlertProvider.provideAlert(alertTitle: title,
                                                                alertMessage: message,
                                                                alertActionTitle: actionTitle,
                                                                onAlertActionTapped: onAlertActionTapped,
                                                                onCanceledActionTapped: onCancelActionTapped)
        viewController.presentViewController(alertController, animated: true, completion: nil)
    }
}

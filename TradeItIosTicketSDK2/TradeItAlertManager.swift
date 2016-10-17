import UIKit

class TradeItAlertManager {
    var linkedBrokerManager = TradeItLauncher.linkedBrokerManager
    var linkBrokerUIFlow = TradeItLinkBrokerUIFlow(linkedBrokerManager: TradeItLauncher.linkedBrokerManager)

    func showGenericError(tradeItErrorResult tradeItErrorResult: TradeItErrorResult,
                            onViewController viewController: UIViewController,
                                             onFinished: () -> Void = {}) {
        let alertTitle = tradeItErrorResult.shortMessage ?? ""
        let messages = (tradeItErrorResult.longMessages as? [String]) ?? []
        let alertMessage = messages.joinWithSeparator(" ")
        let alertActionTitle = "OK"

        self.showOn(viewController: viewController,
                    withAlertTitle: alertTitle,
                    withAlertMessage: alertMessage,
                    withAlertActionTitle: alertActionTitle,
                    onAlertActionTapped: onFinished)
    }

    func show(tradeItErrorResult tradeItErrorResult: TradeItErrorResult,
                onViewController viewController: UIViewController,
                withLinkedBroker linkedBroker: TradeItLinkedBroker,
                                 onFinished : () -> Void) {
        let onAlertActionRelinkAccount: () -> Void = {
            self.linkBrokerUIFlow.presentRelinkBrokerFlow(
                inViewController: viewController,
                linkedBroker: linkedBroker,
                onLinked: { (presentedNavController: UINavigationController, linkedBroker: TradeItLinkedBroker) -> Void in
                    presentedNavController.dismissViewControllerAnimated(true, completion: nil)
                    linkedBroker.refreshAccountBalances(
                        onFinished: onFinished
                    )
                },
                onFlowAborted: { (presentedNavController: UINavigationController) -> Void in
                    onFinished()
                }
            )
        }

        switch tradeItErrorResult.errorCode() {
        case TradeItErrorCode.BROKER_AUTHENTICATION_ERROR?:
            self.showOn(viewController: viewController,
                        withAlertTitle: "Update Login",
                        withAlertMessage: "There seems to be a problem connecting with your \(linkedBroker.linkedLogin.broker) account. Please update your login information.",
                        withAlertActionTitle: "Update",
                        onAlertActionTapped: onAlertActionRelinkAccount,
                        onCancelActionTapped: onFinished)
        case TradeItErrorCode.OAUTH_ERROR?:
            self.showOn(viewController: viewController,
                        withAlertTitle: "Relink \(linkedBroker.linkedLogin.broker) Accounts",
                        withAlertMessage: "For your security, we automatically unlink any accounts that have not been used in the past 30 days. Please relink your accounts.",
                        withAlertActionTitle: "Update",
                        onAlertActionTapped: onAlertActionRelinkAccount,
                        onCancelActionTapped: onFinished)
        default:
            self.showGenericError(tradeItErrorResult: tradeItErrorResult,
                                  onViewController: viewController,
                                  onFinished: onFinished)
        }
    }

    func show(securityQuestion securityQuestion: TradeItSecurityQuestionResult,
              onViewController viewController: UIViewController,
                               onAnswerSecurityQuestion: (withAnswer: String) -> Void,
                               onCancelSecurityQuestion: () -> Void) {
        let alertController = TradeItAlertProvider.provideSecurityQuestionAlertWith(
            alertTitle: "Security Question",
            alertMessage: securityQuestion.securityQuestion ?? "No security question provided.",
            alertActionTitle: "Submit",
            onAnswerSecurityQuestion: onAnswerSecurityQuestion,
            onCancelSecurityQuestion: onCancelSecurityQuestion)
        viewController.presentViewController(alertController, animated: true, completion: nil)
    }

    func showOn(viewController viewController: UIViewController,
                withAlertTitle alertTitle: String,
              withAlertMessage alertMessage: String,
          withAlertActionTitle alertActionTitle: String,
                               onAlertActionTapped: () -> Void = {},
                               onCancelActionTapped: (() -> Void)? = nil) {
        let alertController = TradeItAlertProvider.provideAlert(alertTitle: alertTitle,
                                                                alertMessage: alertMessage,
                                                                alertActionTitle: alertActionTitle,
                                                                onAlertActionTapped: onAlertActionTapped,
                                                                onCanceledActionTapped: onCancelActionTapped)
        viewController.presentViewController(alertController, animated: true, completion: nil)
    }
}

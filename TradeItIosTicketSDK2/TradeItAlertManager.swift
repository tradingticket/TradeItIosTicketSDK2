import UIKit

@objc open class TradeItAlertManager: NSObject {
    fileprivate var alertQueue = TradeItAlertQueue.sharedInstance
    var linkBrokerUIFlow = TradeItLinkBrokerUIFlow()

    open func showError(_ error: TradeItErrorResult,
                          onViewController viewController: UIViewController,
                          onFinished: @escaping () -> Void = {}) {
        let title = error.shortMessage ?? ""
        let messages = (error.longMessages as? [String]) ?? []
        let message = messages.joined(separator: ". ")
        let actionTitle = "OK"

        self.showAlert(onViewController: viewController,
                              withTitle: title,
                            withMessage: message,
                        withActionTitle: actionTitle,
                    onAlertActionTapped: onFinished)
    }

    open func showRelinkError(_ error: TradeItErrorResult,
                                withLinkedBroker linkedBroker: TradeItLinkedBroker,
                                onViewController viewController: UIViewController,
                                onFinished: @escaping () -> Void) {
        let onAlertActionRelinkAccount: () -> Void = {
            self.linkBrokerUIFlow.presentRelinkBrokerFlow(
                inViewController: viewController,
                linkedBroker: linkedBroker,
                onLinked: { presentedNavController, linkedBroker in
                    presentedNavController.dismiss(animated: true, completion: nil)
                    linkedBroker.refreshAccountBalances(onFinished: onFinished)
                },
                onFlowAborted: { _ in onFinished() }
            )
        }

        switch error.errorCode() {
        case .brokerAuthenticationError?:
            self.showAlert(
                onViewController: viewController,
                withTitle: "Update Login",
                withMessage: "There seems to be a problem connecting with your \(linkedBroker.linkedLogin.broker) account. Please update your login information.",
                withActionTitle: "Update",
                onAlertActionTapped: onAlertActionRelinkAccount,
                onCancelActionTapped: onFinished)
        case .oauthError?:
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

    public func promptUserToAnswerSecurityQuestion(_ securityQuestion: TradeItSecurityQuestionResult,
                                                   onViewController viewController: UIViewController,
                                                   onAnswerSecurityQuestion: @escaping (_ withAnswer: String) -> Void,
                                                   onCancelSecurityQuestion: @escaping () -> Void) {
        let alert = TradeItAlertProvider.provideSecurityQuestionAlertWith(
            alertTitle: "Security Question",
            alertMessage: securityQuestion.securityQuestion ?? "No security question provided.",
            multipleOptions: securityQuestion.securityQuestionOptions ?? [],
            alertActionTitle: "Submit",
            onAnswerSecurityQuestion: { answer in
                onAnswerSecurityQuestion(answer)
                self.alertQueue.alertFinished()
            },
            onCancelSecurityQuestion: {
                onCancelSecurityQuestion()
                self.alertQueue.alertFinished()
            }
        )
        alertQueue.add(onViewController: viewController, alert: alert)
    }

    open func showAlert(onViewController viewController: UIViewController,
                          withTitle title: String,
                          withMessage message: String,
                          withActionTitle actionTitle: String,
                          onAlertActionTapped: @escaping () -> Void = {},
                          onCancelActionTapped: (() -> Void)? = nil) {
        let alert = TradeItAlertProvider.provideAlert(
            alertTitle: title,
            alertMessage: message,
            alertActionTitle: actionTitle,
            onAlertActionTapped: {
                onAlertActionTapped()
                self.alertQueue.alertFinished()
            },
            onCanceledActionTapped: {
                onCancelActionTapped?()
                self.alertQueue.alertFinished()
            }
        )

        alertQueue.add(onViewController: viewController, alert: alert)
    }
}

private class TradeItAlertQueue {
    fileprivate static let sharedInstance = TradeItAlertQueue()
    fileprivate typealias AlertContext = (onViewController: UIViewController, alertController: UIAlertController)

    fileprivate var queue: [AlertContext] = []
    fileprivate var alreadyPresentingAlert = false

    fileprivate init() {}

    func add(onViewController viewController: UIViewController, alert: UIAlertController) {
        queue.append((viewController, alert))
        self.showNextAlert()
    }

    fileprivate func alertFinished() {
        alreadyPresentingAlert = false
        showNextAlert()
    }

    fileprivate func showNextAlert() {
        if alreadyPresentingAlert || queue.isEmpty { return }
        let alertContext = queue.removeFirst()
        alreadyPresentingAlert = true
        alertContext.onViewController.present(alertContext.alertController, animated: true, completion: nil)
    }
}

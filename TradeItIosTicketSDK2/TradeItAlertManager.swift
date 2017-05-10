import UIKit

@objc public class TradeItAlertManager: NSObject {
    private var alertQueue = TradeItAlertQueue.sharedInstance
    var linkBrokerUIFlow = TradeItLinkBrokerUIFlow()

    public func showError(_ error: TradeItErrorResult,
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

    public func showRelinkError(error: TradeItErrorResult,
                                withLinkedBroker linkedBroker: TradeItLinkedBroker?,
                                onViewController viewController: UIViewController,
                                oAuthCallbackUrl: URL = TradeItSDK.oAuthCallbackUrl,
                                onFinished: @escaping () -> Void = {}) {
        guard let linkedBroker = linkedBroker else {
            return self.showError(
                error,
                onViewController: viewController,
                onFinished: onFinished
            )
        }

        let onAlertActionRelinkAccount: () -> Void = {
            self.linkBrokerUIFlow.presentRelinkBrokerFlow(
                inViewController: viewController,
                linkedBroker: linkedBroker,
                oAuthCallbackUrl: oAuthCallbackUrl
            )
        }

        switch error.errorCode {
        case .brokerLinkError?:
            self.showAlert(
                onViewController: viewController,
                withTitle: "Update Login",
                withMessage: "There seems to be a problem connecting with your \(linkedBroker.brokerName) login credentials. Please relink.",
                withActionTitle: "Update",
                onAlertActionTapped: onAlertActionRelinkAccount,
                showCancelAction: true,
                onCancelActionTapped: onFinished
            )
        case .oauthError?:
            self.showAlert(
                onViewController: viewController,
                withTitle: "Relink \(linkedBroker.brokerName)",
                withMessage: "For your security, we automatically unlink any accounts that have not been used in the past 30 days. Please relink your accounts.",
                withActionTitle: "Update",
                onAlertActionTapped: onAlertActionRelinkAccount,
                showCancelAction: true,
                onCancelActionTapped: onFinished
            )
        default:
            self.showError(
                error,
                onViewController: viewController,
                onFinished: onFinished
            )
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

    public func showAlert(onViewController viewController: UIViewController,
                          withTitle title: String,
                          withMessage message: String,
                          withActionTitle actionTitle: String,
                          onAlertActionTapped: @escaping () -> Void = {},
                          showCancelAction: Bool = false,
                          onCancelActionTapped: (() -> Void)? = nil) {
        let alert = TradeItAlertProvider.provideAlert(
            alertTitle: title,
            alertMessage: message,
            alertActionTitle: actionTitle,
            onAlertActionTapped: {
                onAlertActionTapped()
                self.alertQueue.alertFinished()
            },
            showCancelAction: showCancelAction,
            onCanceledActionTapped: {
                onCancelActionTapped?()
                self.alertQueue.alertFinished()
            }
        )

        alertQueue.add(onViewController: viewController, alert: alert)
    }
}

private class TradeItAlertQueue {
    static let sharedInstance = TradeItAlertQueue()
    private typealias AlertContext = (onViewController: UIViewController, alertController: UIAlertController)

    private var queue: [AlertContext] = []
    private var alreadyPresentingAlert = false

    private init() {}

    func add(onViewController viewController: UIViewController, alert: UIAlertController) {
        queue.append((viewController, alert))
        self.showNextAlert()
    }

    func alertFinished() {
        alreadyPresentingAlert = false
        showNextAlert()
    }

    func showNextAlert() {
        if alreadyPresentingAlert || queue.isEmpty { return }
        let alertContext = queue.removeFirst()
        alreadyPresentingAlert = true

        if alertContext.onViewController.isViewLoaded && (alertContext.onViewController.view.window != nil) {
            alertContext.onViewController.present(alertContext.alertController, animated: true, completion: nil)
        } else {
            self.alertFinished()
        }
    }
}

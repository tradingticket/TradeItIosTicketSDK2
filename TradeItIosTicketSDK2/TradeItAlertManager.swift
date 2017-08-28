import UIKit

@objc public class TradeItAlertManager: NSObject {
    private var alertQueue = TradeItAlertQueue.sharedInstance
    var linkBrokerUIFlow: LinkBrokerUIFlow = TradeItLinkBrokerUIFlow()

    init(linkBrokerUIFlow: LinkBrokerUIFlow) {
        self.linkBrokerUIFlow = linkBrokerUIFlow

        super.init()
    }

    public override init() {
        super.init()
    }

    public func showAlert(
        forError error: TradeItErrorResult,
        onViewController viewController: UIViewController,
        onFinished: @escaping () -> Void = {}
    ) {
        self.showAlert(
            onViewController: viewController,
            withTitle: error.title,
            withMessage: error.message,
            withActionTitle: "OK",
            onAlertActionTapped: onFinished
        )
    }

    public func showAlertWithAction(
        forError error: TradeItErrorResult,
        withLinkedBroker linkedBroker: TradeItLinkedBroker?,
        onViewController viewController: UIViewController,
        onFinished: @escaping () -> Void = {}
    ) {
        self.showAlertWithAction(
            forError: error,
            withLinkedBroker: linkedBroker,
            onViewController: viewController,
            oAuthCallbackUrl: TradeItSDK.oAuthCallbackUrl,
            onFinished: onFinished
        )
    }


    public func showAlertWithAction(
        forError error: TradeItErrorResult,
        withLinkedBroker linkedBroker: TradeItLinkedBroker?,
        onViewController viewController: UIViewController,
        oAuthCallbackUrl: URL,
        onFinished: @escaping () -> Void = {}
    ) {
        guard let linkedBroker = linkedBroker else {
            return self.showAlert(
                forError: error,
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
        
        let onAlertRetryAuthentication: () -> Void = { () in
            linkedBroker.authenticate(
                onSuccess: {
                    onFinished()
                },
                onSecurityQuestion: { securityQuestion, answerSecurityQuestion, cancelQuestion in
                    self.promptUserToAnswerSecurityQuestion(
                        securityQuestion,
                        onViewController: viewController,
                        onAnswerSecurityQuestion: answerSecurityQuestion,
                        onCancelSecurityQuestion: onFinished
                    )
                },
                onFailure: { (TradeItErrorResult) in
                    onFinished()
                }
            )
        }

        switch error.errorCode {
        case .brokerLinkError?:
            self.showAlert(
                onViewController: viewController,
                withTitle: error.title,
                withMessage: error.message,
                withActionTitle: "Update",
                onAlertActionTapped: onAlertActionRelinkAccount,
                showCancelAction: true,
                onCancelActionTapped: onFinished
            )
        case .oauthError?:
            self.showAlert(
                onViewController: viewController,
                withTitle: error.title,
                withMessage: error.message,
                withActionTitle: "Update",
                onAlertActionTapped: onAlertActionRelinkAccount,
                showCancelAction: true,
                onCancelActionTapped: onFinished
            )
        case .sessionError?:
            self.showAlert(
                onViewController: viewController,
                withTitle: error.title,
                withMessage: error.message,
                withActionTitle: "Retry",
                onAlertActionTapped: onAlertRetryAuthentication,
                showCancelAction: true,
                onCancelActionTapped: onFinished
            )
        default:
            self.showAlert(
                forError: error,
                onViewController: viewController,
                onFinished: onFinished
            )
        }
    }

    public func promptUserToAnswerSecurityQuestion(
        _ securityQuestion: TradeItSecurityQuestionResult,
        onViewController viewController: UIViewController,
        onAnswerSecurityQuestion: @escaping (_ withAnswer: String) -> Void,
        onCancelSecurityQuestion: @escaping () -> Void
    ) {
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

    public func showAlert(
        onViewController viewController: UIViewController,
        withTitle title: String,
        withMessage message: String,
        withActionTitle actionTitle: String,
        onAlertActionTapped: @escaping () -> Void = {},
        showCancelAction: Bool = false,
        onCancelActionTapped: (() -> Void)? = nil
    ) {
        NotificationCenter.default.post(
            name: TradeItNotification.Name.errorShown,
            object: nil,
            userInfo: [
                TradeItNotification.UserInfoKey.view: viewController.classForCoder,
                TradeItNotification.UserInfoKey.errorTitle: title,
                TradeItNotification.UserInfoKey.errorMessage: message
            ]
        )

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

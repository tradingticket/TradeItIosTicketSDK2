import UIKit

class FakeTradeItAlert: TradeItAlert {
    let calls = SpyRecorder()

    override func showErrorAlert(onViewController viewController: UIViewController,
                                                  title: String,
                                                  message: String,
                                                  actionTitle: String,
                                                  onAlertDismissed: () -> Void) {
        self.calls.record(#function,
                          args: [
                            "onViewController": viewController,
                            "title": title,
                            "message": message,
                            "actionTitle": actionTitle,
                            "onAlertDismissed": onAlertDismissed,
                          ])
    }
    
    override func showTradeItErrorResultAlert(onViewController viewController: UIViewController,
                                                               errorResult: TradeItErrorResult,
                                                               onAlertDismissed: () -> Void) {
        self.calls.record(#function,
                          args: [
                            "onViewController": viewController,
                            "errorResult": errorResult,
                            "onAlertDismissed": onAlertDismissed
                          ])
    }
    
    override func showValidationAlert(onViewController viewController: UIViewController,
                                                       title: String,
                                                       message: String,
                                                       actionTitle: String,
                                                       onValidate: () -> Void,
                                                       onCancel: () -> Void) {
        self.calls.record(#function,
                          args: [
                            "onViewController": viewController,
                            "title": title,
                            "message": message,
                            "actionTitle": actionTitle,
                            "onValidate": onValidate,
                            "onCancel": onCancel
                          ])
    }
}

import UIKit
import TradeItIosEmsApi

class FakeTradeItAlert: TradeItAlert {
    let calls = SpyRecorder()
    
    override func showErrorAlert(onController controller: UIViewController, withTitle title: String,  withMessage message: String, withActionTitle actionTitle: String, withCompletion completion: () -> Void) {
        self.calls.record(#function,
                          args: [
                            "onController": controller,
                            "withTitle": title,
                            "withMessage": message,
                            "withActionTitle": actionTitle,
                            "withCompletion": completion,
                            
            ])
    }
    
    override func showTradeItErrorResultAlert(onController controller: UIViewController, withError tradeItErrorResult: TradeItErrorResult, withCompletion completion: () -> Void) {
        self.calls.record(#function,
                          args: [
                            "onController": controller,
                            "withError": tradeItErrorResult,
                            "withCompletion": completion
            ])
    }
    
    override func showValidationAlert(onController controller: UIViewController, withTitle title: String, withMessage message: String, withActionOkTitle actionTitle: String, onValidate: () -> Void, onCancel: () -> Void, withCompletion completion: () -> Void) {
        self.calls.record(#function,
                          args: [
                            "onController": controller,
                            "withTitle": title,
                            "withMessage": message,
                            "withActionOkTitle": actionTitle,
                            "onValidate": onValidate,
                            "onCancel": onCancel,
                            "withCompletion": completion
            ])
    }
}

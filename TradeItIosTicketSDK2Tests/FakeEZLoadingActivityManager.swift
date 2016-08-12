import Foundation
import UIKit

public class FakeEZLoadingActivityManager: EZLoadingActivityManager {
    let calls = SpyRecorder()

    override func show(text text: String, disableUI: Bool) -> Bool {
        self.calls.record(#function, args: [
            "text": text,
            "disableUI": disableUI
        ])
        return true
    }

    override func showOnController(text text: String,
                                        disableUI: Bool,
                                        controller: UIViewController) -> Bool {
        self.calls.record(#function, args: [
            "text": text,
            "disableUI": disableUI,
            "controller": controller
        ])
        return true
    }

    override func hide() -> Bool {
        self.calls.record(#function)
        return true
    }
}
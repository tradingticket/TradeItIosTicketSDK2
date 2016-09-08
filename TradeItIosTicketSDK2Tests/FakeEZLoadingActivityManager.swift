import Foundation
import UIKit

public class FakeEZLoadingActivityManager: EZLoadingActivityManager {
    var spinnerIsShowing = false
    var spinnerText = ""

    override func show(text text: String, disableUI: Bool) -> Bool {
        self.spinnerIsShowing = true
        self.spinnerText = text
        return true
    }

    override func showOnController(text text: String,
                                        disableUI: Bool,
                                        controller: UIViewController) -> Bool {
        assert(false, "=====> I guess we do call showOnController after all...")
        return true
    }

    override func hide() -> Bool {
        self.spinnerIsShowing = false
        self.spinnerText = ""
        return true
    }
}
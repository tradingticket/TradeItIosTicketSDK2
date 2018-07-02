import UIKit

extension UIButton {
    @objc public func enable() {
        self.isEnabled = true
        self.alpha = 1.0
    }

    @objc public func disable() {
        self.isEnabled = false
        self.alpha = 0.5
    }
}

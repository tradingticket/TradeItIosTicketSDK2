import Foundation
import UIKit

class TradeItKeyboardOffsetConstraintManager: NSObject {
    var bottomConstraintOriginalConstant: CGFloat
    let bottomConstraintOffset: CGFloat = 82.0
    let bottomConstraint: NSLayoutConstraint
    let viewController: UIViewController

    init(bottomConstraint: NSLayoutConstraint, viewController: UIViewController) {
        self.bottomConstraint = bottomConstraint
        self.bottomConstraintOriginalConstant = self.bottomConstraint.constant
        self.viewController = viewController

        super.init()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.keyboardNotification(_:)),
            name: UIResponder.keyboardWillChangeFrameNotification,
            object: nil
        )
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc func keyboardNotification(_ notification: Notification) {
        if let userInfo = (notification as NSNotification).userInfo {
            let endFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue ?? CGRect()
            let duration:TimeInterval = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSDecimalNumber)?.doubleValue ?? 0
            let animationCurveRawNSN = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSDecimalNumber
            let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIView.AnimationOptions().rawValue
            let animationCurve:UIView.AnimationOptions = UIView.AnimationOptions(rawValue: animationCurveRaw)

            if endFrame.origin.y >= UIScreen.main.bounds.size.height {
                self.bottomConstraint.constant = bottomConstraintOriginalConstant
            } else {
                self.bottomConstraint.constant = endFrame.size.height + bottomConstraintOriginalConstant - bottomConstraintOffset
            }

            UIView.animate(
                withDuration: duration,
                delay: TimeInterval(0),
                options: animationCurve,
                animations: { self.viewController.view.layoutIfNeeded() },
                completion: nil
            )
        }
    }

}

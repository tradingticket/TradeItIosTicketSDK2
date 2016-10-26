import UIKit

class KeyboardViewController: TradeItViewController {
    
    var submitButtonBottomSpaceConstraintConstant:CGFloat = 0.0
    
    @IBOutlet weak var submitButtonBottomSpaceConstraint: NSLayoutConstraint!

    override func viewDidLoad() {
        guard (submitButtonBottomSpaceConstraint != nil) else {
            assertionFailure("TradeItSdk ERROR: Class inherits from KeyboardViewController without hooking up submitButtonBottomSpaceConstraint IBOoutlet!")
            return
        }
        
        super.viewDidLoad()
        self.submitButtonBottomSpaceConstraintConstant = self.submitButtonBottomSpaceConstraint.constant
        NotificationCenter.default.addObserver(self,
                                                         selector: #selector(self.keyboardNotification(_:)),
                                                         name: NSNotification.Name.UIKeyboardWillChangeFrame,
                                                         object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func keyboardNotification(_ notification: Notification) {
        if let userInfo = (notification as NSNotification).userInfo {
            let endFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue ?? CGRect()
            let duration:TimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSDecimalNumber)?.doubleValue ?? 0
            let animationCurveRawNSN = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSDecimalNumber
            let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIViewAnimationOptions().rawValue
            let animationCurve:UIViewAnimationOptions = UIViewAnimationOptions(rawValue: animationCurveRaw)
            
            if endFrame.origin.y >= UIScreen.main.bounds.size.height {
                self.submitButtonBottomSpaceConstraint?.constant = submitButtonBottomSpaceConstraintConstant
            } else {
                self.submitButtonBottomSpaceConstraint?.constant = endFrame.size.height + submitButtonBottomSpaceConstraintConstant
            }
            
            UIView.animate(withDuration: duration,
                                       delay: TimeInterval(0),
                                       options: animationCurve,
                                       animations: { self.view.layoutIfNeeded() },
                                       completion: nil)
        }
    }
}

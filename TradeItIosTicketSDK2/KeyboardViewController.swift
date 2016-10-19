import UIKit

class KeyboardViewController: UIViewController {
    
    var submitButtonBottomSpaceConstraintConstant:CGFloat = 0.0
    
    @IBOutlet weak var submitButtonBottomSpaceConstraint: NSLayoutConstraint!

    override func viewDidLoad() {
        guard (submitButtonBottomSpaceConstraint != nil) else {
            assertionFailure("TradeItSdk ERROR: Class inherits from KeyboardViewController without hooking up submitButtonBottomSpaceConstraint IBOoutlet!")
            return
        }
        
        super.viewDidLoad()
        self.submitButtonBottomSpaceConstraintConstant = self.submitButtonBottomSpaceConstraint.constant
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: #selector(self.keyboardNotification(_:)),
                                                         name: UIKeyboardWillChangeFrameNotification,
                                                         object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func keyboardNotification(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            let endFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.CGRectValue() ?? CGRect()
            let duration:NSTimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
            let animationCurveRawNSN = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber
            let animationCurveRaw = animationCurveRawNSN?.unsignedLongValue ?? UIViewAnimationOptions.CurveEaseInOut.rawValue
            let animationCurve:UIViewAnimationOptions = UIViewAnimationOptions(rawValue: animationCurveRaw)
            
            if endFrame.origin.y >= UIScreen.mainScreen().bounds.size.height {
                self.submitButtonBottomSpaceConstraint?.constant = submitButtonBottomSpaceConstraintConstant
            } else {
                self.submitButtonBottomSpaceConstraint?.constant = endFrame.size.height + submitButtonBottomSpaceConstraintConstant
            }
            
            UIView.animateWithDuration(duration,
                                       delay: NSTimeInterval(0),
                                       options: animationCurve,
                                       animations: { self.view.layoutIfNeeded() },
                                       completion: nil)
        }
    }
}

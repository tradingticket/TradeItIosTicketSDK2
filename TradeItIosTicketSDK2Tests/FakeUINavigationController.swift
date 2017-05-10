import UIKit

class FakeUINavigationController: UINavigationController {

    let calls = SpyRecorder()
    
    override func viewDidLoad() {
        self.calls.record(#function)
    }

    override func didReceiveMemoryWarning() {
        self.calls.record(#function)
    }
    
    override func setViewControllers(_ viewControllers: [UIViewController], animated: Bool) {
        self.calls.record(#function, args: [
            "viewControllers": viewControllers,
            "animated": animated
            ])
    }
    
    override func dismiss(animated flag: Bool, completion: (() -> Void)?) {
        self.calls.record(#function, args: [
            "flag": flag,
            "completion": completion
            ])
    }

}

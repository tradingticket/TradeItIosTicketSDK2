import UIKit

class TradeItViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationItem()
    }
    
    func configureNavigationItem() {
        guard let viewControllers = self.navigationController?.viewControllers else {
            self.createCloseButton()
            return
        }
        
        if viewControllers.count == 1 {
            self.createCloseButton()
        }
    }
    
    func createCloseButton() {
        let closeButtonItem = UIBarButtonItem(title: "Close", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(closeButtonWasTapped(_:)))
        
        self.navigationItem.rightBarButtonItem = closeButtonItem
    }
    
    func closeButtonWasTapped(sender: UIBarButtonItem) {
        guard let viewControllers = self.navigationController?.viewControllers where viewControllers.count > 1 else {
            self.dismissViewControllerAnimated(true, completion: nil)
            return
        }
        self.navigationController?.popViewControllerAnimated(true)
        
    }

}


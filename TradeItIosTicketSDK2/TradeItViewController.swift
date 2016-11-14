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
        let closeButtonItem = UIBarButtonItem(title: "Close", style: UIBarButtonItemStyle.plain, target: self, action: #selector(closeButtonWasTapped(_:)))
        
        self.navigationItem.rightBarButtonItem = closeButtonItem
    }
    
    func closeButtonWasTapped(_ sender: UIBarButtonItem) {
        if let viewControllers = self.navigationController?.viewControllers , viewControllers.count > 1 {
            _ = self.navigationController?.popViewController(animated: true)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
}

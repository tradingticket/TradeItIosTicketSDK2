import UIKit

class TradeItSymbolSearchViewController: UIViewController, TradeItSymbolSearchTableViewManagerDelegate  {

    @IBOutlet weak var symbolResultsTableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    let marketDataService = TradeItLauncher.marketDataService
    var symbolSearchTableViewManager = TradeItSymbolSearchTableViewManager()
    let searchController = UISearchController(searchResultsController: nil)
    
    weak var delegate: TradeItSymbolSearchViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.activityIndicator.hidesWhenStopped = true
        self.symbolSearchTableViewManager.symbolResultsTableView = symbolResultsTableView
        
        self.symbolSearchTableViewManager.searchController = self.searchController
        definesPresentationContext = true

        self.symbolSearchTableViewManager.delegate = self
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        dispatch_async(dispatch_get_main_queue(), { self.searchController.searchBar.becomeFirstResponder() })
    }
    
    // MARK: TradeItSymbolSearchTableViewManagerDelegate methods
    
    func symbolSearchWasCalledWith(searchSymbol: String) {
        self.activityIndicator.startAnimating()
        self.marketDataService.symbolLookup(searchSymbol, onSuccess: { results in
            self.activityIndicator.stopAnimating()
            self.symbolSearchTableViewManager.updateSymbolResults(withResults: results)
            }, onFailure: { error in
                self.activityIndicator.stopAnimating()
                self.symbolSearchTableViewManager.updateSymbolResults(withResults: [])
        })
    }
    
    func symbolWasSelected(selectedSymbol: String) {
        self.delegate?.symbolSearchViewController(self, didSelectSymbol: selectedSymbol)
    }
}

protocol TradeItSymbolSearchViewControllerDelegate: class {
    func symbolSearchViewController(symbolSearchViewController: TradeItSymbolSearchViewController,
                                    didSelectSymbol selectedSymbol: String)

    func symbolSearchCancelled(forSymbolSearchViewController symbolSearchViewController: TradeItSymbolSearchViewController)
}

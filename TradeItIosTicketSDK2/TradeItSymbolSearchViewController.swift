import UIKit
import TradeItIosEmsApi

class TradeItSymbolSearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var symbolSearchResultsTableView: UITableView!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var searchResultTableView: UITableView!

    let marketDataService = TradeItLauncher.marketDataService
    private var symbolSearchResults: [TradeItSymbolLookupCompany] = []
    weak var delegate: TradeItSymbolSearchViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.activityIndicator.hidesWhenStopped = true
        setupSearchTextField()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        searchTextField.becomeFirstResponder()
    }

    // MARK: Private

    private func setupSearchTextField() {
        searchTextField.delegate = self
        let searchLabel = UILabel()
        searchLabel.text = " 🔍"
        searchLabel.sizeToFit()
        searchTextField.leftView = searchLabel
        searchTextField.leftViewMode = .Always
    }

    // MARK: UITextFieldDelegate

    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        let currentText: NSString = textField.text ?? ""
        let resultText = currentText.stringByReplacingCharactersInRange(range, withString: string)

        self.activityIndicator.startAnimating()

        self.marketDataService.symbolLookup(
            resultText,
            onSuccess: { results in
                self.activityIndicator.stopAnimating()
                self.symbolSearchResults = results
                self.searchResultTableView.reloadData()
            },
            onFailure: { error in
                self.activityIndicator.stopAnimating()
            })

        return true
    }

    // MARK: UITableViewDelegate

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        guard let selectedSymbol = symbolSearchResults[safe: indexPath.row]?.symbol else { return }

        self.delegate?.symbolSearchViewController(self, didSelectSymbol: selectedSymbol)
    }


    // MARK: UITableViewDataSource

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.symbolSearchResults.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SYMBOL_SEARCH_CELL_ID") as! TradeItSymbolSearchTableViewCell
        let symbolResult = self.symbolSearchResults[indexPath.row]
        cell.populateWith(symbolResult)

        return cell
    }
}

protocol TradeItSymbolSearchViewControllerDelegate: class {
    func symbolSearchViewController(symbolSearchViewController: TradeItSymbolSearchViewController,
                                    didSelectSymbol selectedSymbol: String)
}

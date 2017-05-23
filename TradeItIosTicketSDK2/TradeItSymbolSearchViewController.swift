import UIKit

class TradeItSymbolSearchViewController: TradeItViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var symbolSearchResultsTableView: UITableView!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var searchResultTableView: UITableView!
    @IBOutlet weak var adContainer: UIView!

    private var symbolSearchResults: [TradeItSymbolLookupCompany] = []
    weak var delegate: TradeItSymbolSearchViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.activityIndicator.hidesWhenStopped = true
        setupSearchTextField()

        TradeItSDK.adService?.configure(adContainer: adContainer, rootViewController: self, pageType: .trading, position: .bottom)
    }
    
    override func viewDidAppear(_ animated: Bool) {
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
        searchTextField.leftViewMode = .always
    }

    // MARK: UITextFieldDelegate

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText: NSString = textField.text as NSString? ?? ""
        let resultText = currentText.replacingCharacters(in: range, with: string)

        self.activityIndicator.startAnimating()

        TradeItSDK.symbolService.symbolLookup(
            resultText,
            onSuccess: { results in
                self.activityIndicator.stopAnimating()
                self.symbolSearchResults = results
                self.searchResultTableView.reloadData()
            },
            onFailure: { error in
                self.activityIndicator.stopAnimating()
            }
        )

        return true
    }

    // MARK: UITableViewDelegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let selectedSymbol = symbolSearchResults[safe: indexPath.row]?.symbol else { return }

        self.delegate?.symbolSearchViewController(self, didSelectSymbol: selectedSymbol)
    }


    // MARK: UITableViewDataSource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.symbolSearchResults.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SYMBOL_SEARCH_CELL_ID") as! TradeItSymbolSearchTableViewCell
        let symbolResult = self.symbolSearchResults[indexPath.row]
        cell.populateWith(symbolResult)
        return cell
    }
}

protocol TradeItSymbolSearchViewControllerDelegate: class {
    func symbolSearchViewController(_ symbolSearchViewController: TradeItSymbolSearchViewController,
                                    didSelectSymbol selectedSymbol: String)
}

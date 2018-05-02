import UIKit

class TradeItSymbolSearchViewController: TradeItViewController, UITableViewDelegate, UITextFieldDelegate {
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var symbolSearchResultsTableView: UITableView!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var adContainer: UIView!

    weak var delegate: TradeItSymbolSearchViewControllerDelegate?
    weak var dataSource: SymbolDataSource?

    override func viewDidLoad() {
        symbolSearchResultsTableView.dataSource = dataSource
        super.viewDidLoad()

        self.activityIndicator.hidesWhenStopped = true
        setupSearchTextField()

        TradeItSDK.adService.populate(
            adContainer: adContainer,
            rootViewController: self,
            pageType: .trading,
            position: .bottom,
            broker: nil,
            symbol: nil,
            instrumentType: nil,
            trackPageViewAsPageType: false
        )
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
        searchTextField.autocorrectionType = .no
        searchTextField.returnKeyType = .done
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchTextField.resignFirstResponder()
        return true
    }

    // MARK: UITextFieldDelegate

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let originalText: NSString = textField.text as NSString? ?? ""
        let modifiedText = originalText.replacingCharacters(in: range, with: string)

        textField.text = modifiedText

        guard let symbolDataSource = symbolSearchResultsTableView.dataSource as? SymbolDataSource
            else { return false } // TODO: Should it be true?

        self.activityIndicator.startAnimating()
        symbolDataSource.searchByTextField(
            textField: textField,
            onSuccess: {
                self.activityIndicator.stopAnimating()
                self.symbolSearchResultsTableView.reloadData()
            },
            onFailure: {
                self.activityIndicator.stopAnimating()
            }
        )

        return false
    }

    // MARK: UITableViewDelegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? TradeItSymbolSearchTableViewCell,
            let selectedSymbol = cell.symbolLabel.text
            else { return }

        self.delegate?.symbolSearchViewController(self, didSelectSymbol: selectedSymbol)
    }
}

protocol TradeItSymbolSearchViewControllerDelegate: class {
    func symbolSearchViewController(
        _ symbolSearchViewController: TradeItSymbolSearchViewController,
        didSelectSymbol selectedSymbol: String
    )
}

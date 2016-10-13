import UIKit
import TradeItIosEmsApi


class TradeItSymbolSearchTableViewManager: NSObject, UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating, UISearchControllerDelegate {
    private var symbolResults: [TradeItSymbolLookupCompany] = []
    private var _table: UITableView?
    var symbolResultsTableView: UITableView? {
        get {
            return _table
        }
        
        set(newTable) {
            if let newTable = newTable {
                newTable.dataSource = self
                newTable.delegate = self
                _table = newTable
            }
        }
    }
    private var _searchController: UISearchController?
    var searchController: UISearchController? {
        get {
            return _searchController
        }

        set(searchController) {
            if let searchController = searchController {
                addSearchController(searchController: searchController)
                _searchController = searchController
            }
        }
    }

    weak var delegate: TradeItSymbolSearchTableViewManagerDelegate?

    func updateSymbolResults(withResults symbolResults: [TradeItSymbolLookupCompany]) {
        self.symbolResults = symbolResults
        self.symbolResultsTableView?.reloadData()
    }

    // MARK: UITableViewDelegate

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let selectedSymbolResult = self.symbolResults[indexPath.row]
        var symbol = TradeItPresenter.MISSING_DATA_PLACEHOLDER
        if selectedSymbolResult.symbol != nil {
            symbol = selectedSymbolResult.symbol!
        }
        self.delegate?.symbolWasSelected(symbol)

        // If you don't set searchController.active to false, the searchController will intercept the next
        // call to dismissViewController, preventing the search screen from being dismissed
        self.searchController?.active = false
    }

    // MARK: UITableViewDataSource

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.symbolResults.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SYMBOL_SEARCH_CELL_ID") as! TradeItSymbolSearchTableViewCell
        let symbolResult = self.symbolResults[indexPath.row]
        cell.populateWith(symbolResult)
        return cell
    }
    
    // MARK: UISearchResultsUpdating
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        let searchSymbol = searchController.searchBar.text!

        if (searchSymbol != "") {
            self.delegate?.symbolSearchWasCalledWith(searchSymbol)
        } else {
            self.updateSymbolResults(withResults: [])
        }
    }

    // MARK: UISearchControllerDelegate

    func didPresentSearchController(searchController: UISearchController) {
        searchController.searchBar.showsCancelButton = false
    }

    // MARK: Private
    
    func addSearchController(searchController searchController: UISearchController) {
        searchController.delegate = self
        searchController.searchResultsUpdater = self
        searchController.searchBar.placeholder = "Enter a symbol"
        searchController.dimsBackgroundDuringPresentation = false
        self.symbolResultsTableView!.tableHeaderView = searchController.searchBar
    }
}

protocol TradeItSymbolSearchTableViewManagerDelegate: class{
    func symbolSearchWasCalledWith(searchSymbol: String)
    func symbolWasSelected(selectedSymbol: String)
}

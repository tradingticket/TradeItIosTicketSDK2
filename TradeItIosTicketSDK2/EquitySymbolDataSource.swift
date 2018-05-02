import PromiseKit

protocol SymbolDataSource: UITableViewDataSource {
    var results: [TradeItSymbol] { get }

    init(linkedBrokerAccount: TradeItLinkedBrokerAccount)

    func searchByTextField(
        textField: UITextField,
        onSuccess: @escaping () -> Void,
        onFailure: @escaping () -> Void
    )
}

class CryptoSymbolDataSource: NSObject, SymbolDataSource {
    var results: [TradeItSymbol] = []

    private let linkedBrokerAccount: TradeItLinkedBrokerAccount
    private var resultsPromise: Promise<[TradeItSymbol]>? = nil

    required init(linkedBrokerAccount: TradeItLinkedBrokerAccount) {
        self.linkedBrokerAccount = linkedBrokerAccount
    }

    // TODO: Can this just be promises all the way?
    func searchByTextField(
        textField: UITextField,
        onSuccess: @escaping () -> Void,
        onFailure: @escaping () -> Void
    ) {
        let queryText = textField.text ?? ""

        getAllSymbolsPromise().then { (symbols) -> Void in
            let topResults = symbols.filter { $0.symbol?.contains(queryText) ?? false }.prefix(20)
            self.results = Array(topResults)
            onSuccess()
        }.catch { error in
            print("ERROR") // TODO: Handle better
            onFailure()
        }
    }

    // TODO: Move to getter?
    private func getAllSymbolsPromise() -> Promise<[TradeItSymbol]> {
        if let resultsPromise = self.resultsPromise { return resultsPromise }

        let resultsPromise = Promise<[TradeItSymbol]> { fulfill, reject in TradeItSDK.symbolService.cryptoSymbols(
                account: linkedBrokerAccount,
                onSuccess: { symbolStrings in
                    let symbols = symbolStrings.map { (symbolString) -> TradeItSymbol in
                        let symbol = TradeItSymbol()
                        symbol.symbol = symbolString
                        return symbol
                    }
                    fulfill(symbols)
                },
                onFailure: reject
            )
        }

        self.resultsPromise = resultsPromise

        return resultsPromise
    }

    // MARK: UITableViewDataSource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.results.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SYMBOL_SEARCH_CELL_ID") as! TradeItSymbolSearchTableViewCell
        let symbolResult = self.results[indexPath.row]
        cell.populateWith(symbolResult)
        return cell
    }
}

class EquitySymbolDataSource: NSObject, SymbolDataSource {
    var results: [TradeItSymbol] = []

    required init(linkedBrokerAccount: TradeItLinkedBrokerAccount) {
        // Unused for equities
    }

    func searchByTextField(
        textField: UITextField,
        onSuccess: @escaping () -> Void,
        onFailure: @escaping () -> Void
    ) {
        let queryText = textField.text ?? ""
        TradeItSDK.symbolService.symbolLookup(
            queryText,
            onSuccess: { results in
                let currentQueryText = textField.text

                if currentQueryText == queryText {
                    self.results = results
                    onSuccess()
                }
            },
            onFailure: { error in
                onFailure()
            }
        )
    }

    // MARK: UITableViewDataSource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.results.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SYMBOL_SEARCH_CELL_ID") as! TradeItSymbolSearchTableViewCell
        let symbolResult = self.results[indexPath.row]
        cell.populateWith(symbolResult)
        return cell
    }
}

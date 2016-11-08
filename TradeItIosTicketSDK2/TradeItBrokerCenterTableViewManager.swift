import UIKit

class TradeItBrokerCenterTableViewManager: NSObject, UITableViewDelegate, UITableViewDataSource {
    private var _table: UITableView?

    // MARK: UITableViewDelegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // TODO
    }

    // MARK: UITableViewDataSource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // TODO
        //return self.symbolResults.count
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let brokerCenterNib = UINib(nibName: "TTSDKBrokerCenterCell", bundle: TradeItBundleProvider.provide())

        _table?.register(brokerCenterNib, forCellReuseIdentifier: "BROKER_CENTER_TABLE_CELL")
        //_table?.register(UITableViewCell.self, forCellReuseIdentifier: "BROKER_CENTER_TABLE_CELL")


        let cell = tableView.dequeueReusableCell(withIdentifier: "BROKER_CENTER_TABLE_CELL") as! TTSDKBrokerCenterTableViewCell
        //cell.configure(with: <#T##TradeItBrokerCenterBroker!#>)
        //let symbolResult = self.symbolResults[indexPath.row]
        //cell.populateWith(symbolResult)
        return cell
    }
}

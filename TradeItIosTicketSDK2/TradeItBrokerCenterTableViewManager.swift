import UIKit

class TradeItBrokerCenterTableViewManager: NSObject, UITableViewDelegate, UITableViewDataSource {
    private var _table: UITableView?
    private var publishers: [TradeItBrokerCenterBroker] = []

    var publishersTable: UITableView? {
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

    func update(publishers: [TradeItBrokerCenterBroker]) {
        self.publishers = publishers
        self.publishersTable?.reloadData()
    }

    // MARK: UITableViewDelegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // TODO
    }

    // MARK: UITableViewDataSource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.publishers.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let brokerCenterNib = UINib(nibName: "TTSDKBrokerCenterCell", bundle: TradeItBundleProvider.provide())

        _table?.register(brokerCenterNib, forCellReuseIdentifier: "BROKER_CENTER_TABLE_CELL")
        //_table?.register(UITableViewCell.self, forCellReuseIdentifier: "BROKER_CENTER_TABLE_CELL")


        let cell = tableView.dequeueReusableCell(withIdentifier: "BROKER_CENTER_TABLE_CELL") as! TTSDKBrokerCenterTableViewCell
        let publisher = self.publishers[indexPath.row]
        cell.configure(with: publisher)
        return cell
    }
}

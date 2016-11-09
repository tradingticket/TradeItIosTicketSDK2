import UIKit

class TradeItBrokerCenterTableViewManager: NSObject, UITableViewDelegate, UITableViewDataSource {
    private var _table: UITableView?
    private var publishers: [TradeItBrokerCenterBroker] = []
    private let bundle = TradeItBundleProvider.provide()

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

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 293.0;
    }

    // MARK: UITableViewDataSource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.publishers.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let brokerCenterNib = UINib(nibName: "TTSDKBrokerCenterCell", bundle: TradeItBundleProvider.provide())

        _table?.register(brokerCenterNib, forCellReuseIdentifier: "BROKER_CENTER_TABLE_CELL")

        let cell = tableView.dequeueReusableCell(withIdentifier: "BROKER_CENTER_TABLE_CELL") as! TTSDKBrokerCenterTableViewCell
        let publisher = self.publishers[indexPath.row]
        cell.configure(with: publisher)
        if let broker = publisher.broker {
            cell.addImage(image(forBroker: broker))
        }
        return cell
    }

    private func image(forBroker broker: String) -> UIImage? {
        let filename =  "\(broker)_logo.png"
        return UIImage(named: filename, in: bundle, compatibleWith: nil)
    }
}

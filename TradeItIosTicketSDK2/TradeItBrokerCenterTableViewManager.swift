import UIKit

class TradeItBrokerCenterTableViewManager: NSObject, UITableViewDelegate, UITableViewDataSource {
    private let bundle = TradeItBundleProvider.provide()
    private var _table: UITableView?
    private var publishers: [TradeItBrokerCenterBroker] = []
    private var selectedPublisherIndex = -1

    var publishersTable: UITableView? {
        get {
            return _table
        }

        set(newTable) {
            if let newTable = newTable {
                newTable.dataSource = self
                newTable.delegate = self
                newTable.rowHeight = UITableViewAutomaticDimension
                newTable.estimatedRowHeight = 600
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
        // if the user click on the already expanded row, deselect it
        if self.selectedPublisherIndex == indexPath.row {
            self.selectedPublisherIndex = -1
            self.reloadTableViewAtIndexPath([indexPath])
        /*} else if self.selectedPublisherIndex != -1 {
            let prevPath = IndexPath(row: self.selectedPublisherIndex, section: 0)
            self.selectedPublisherIndex = indexPath.row
            self.reloadTableViewAtIndexPath([prevPath, indexPath])*/
        } else {
            self.selectedPublisherIndex = indexPath.row
            self.reloadTableViewAtIndexPath([indexPath])
        }
    }

    private func reloadTableViewAtIndexPath(_ indexPaths: [IndexPath]) {
        self.publishersTable?.beginUpdates()
        self.publishersTable?.reloadRows(at: indexPaths, with: .automatic)
        self.publishersTable?.endUpdates()
        //self.publishersTable?.selectRow(at: indexPaths.last, animated: true, scrollPosition: .top)
    }


    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 300//UITableViewAutomaticDimension
    }

    // MARK: UITableViewDataSource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.publishers.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let brokerCenterNib = UINib(nibName: "TTSDKBrokerCenterCell", bundle: TradeItBundleProvider.provide())

        publishersTable?.register(brokerCenterNib, forCellReuseIdentifier: "BROKER_CENTER_TABLE_CELL")

        let cell = tableView.dequeueReusableCell(withIdentifier: "BROKER_CENTER_TABLE_CELL") as! TTSDKBrokerCenterTableViewCell
        let publisher = self.publishers[indexPath.row]
        cell.configure(with: publisher)
        cell.addImage(image(forBroker: publisher.broker))
        //cell.configureSelectedState(self.selectedPublisherIndex == indexPath.row)
        cell.configureSelectedState(true)
        return cell
    }

    private func image(forBroker broker: String?) -> UIImage? {
        guard let broker = broker else { return nil }
        let filename =  "\(broker)_logo.png"
        return UIImage(named: filename, in: bundle, compatibleWith: nil)
    }
}

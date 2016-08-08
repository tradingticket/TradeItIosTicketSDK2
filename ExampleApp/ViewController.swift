import UIKit
import TradeItIosTicketSDK2

enum Action: Int {
    case LaunchSdk = 0
    case ENUM_COUNT
}

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var table: UITableView!

    let tradeItLauncher: TradeItLauncher = TradeItLauncher()

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // Mark: - UITableViewDelegate

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        guard let action = Action(rawValue: indexPath.row) else { return }

        switch action {
        case .LaunchSdk:
            self.tradeItLauncher.launchTradeItFromViewController(self)
        default:
            return
        }
    }

    // Mark: - UITableViewDataSource

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Action.ENUM_COUNT.rawValue;
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "CELL_IDENTIFIER"

        var cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier)

        if cell == nil {
            cell = UITableViewCell.init(style: UITableViewCellStyle.Default, reuseIdentifier: cellIdentifier)
        }

        if let action = Action(rawValue: indexPath.row) {
            cell?.textLabel?.text = "\(action)"
        }
        
        return cell!
    }
}
import UIKit

class TradeItWebViewController: UIViewController, UIWebViewDelegate {

    @IBOutlet weak var webView: UIWebView!
    var url = ""
    var pageTitle = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Loading...";
        guard let urlObject = URL (string: self.url) else {
            print("TradeIt SDK ERROR: Invalid url provided: " + self.url)
            _ = self.navigationController?.popViewController(animated: true)
            return
        }
        self.webView.loadRequest(URLRequest(url: urlObject))
    }

    func webViewDidFinishLoad(_ webView: UIWebView) {
        self.navigationItem.title = self.pageTitle;
    }
    

   
}

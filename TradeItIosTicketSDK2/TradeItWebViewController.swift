import UIKit

class TradeItWebViewController: UIViewController, UIWebViewDelegate {

    @IBOutlet weak var webView: UIWebView!
    var url = ""
    var pageTitle = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Loading...";
        self.webView.loadRequest(URLRequest(url: URL (string: self.url)!))
    }

    func webViewDidFinishLoad(_ webView: UIWebView) {
        self.navigationItem.title = self.pageTitle;
    }
    

   
}

import UIKit

@objc public protocol ActivityIndicatorFactory {
    func build(frame: CGRect) -> UIView
}

class DefaultActivityIndicatorFactory: ActivityIndicatorFactory {
    func build(frame: CGRect) -> UIView {
        let view = UIActivityIndicatorView(frame: frame)
        view.color = UIColor.gray
        view.startAnimating()
        return view
    }
}

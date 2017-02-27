extension UIButton {
    public func enable() {
        self.isEnabled = true
        self.alpha = 1.0
    }

    public func disable() {
        self.isEnabled = false
        self.alpha = 0.5
    }
}

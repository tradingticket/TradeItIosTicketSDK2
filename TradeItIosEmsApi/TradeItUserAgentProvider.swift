class TradeItUserAgentProvider: NSObject {

    static let userAgent: String = {
        var bundleDict = Bundle.main.infoDictionary
        var appName = bundleDict?["CFBundleName"] as? String
        var appVersion = bundleDict?["CFBundleShortVersionString"] as? String
        
        var appDescriptor = "\(appName ?? "")/\(appVersion ?? "")"
        
        var device = UIDevice.current
        var systemVersion = device.systemVersion
        
        var osDescriptor = "\("iOS") \(systemVersion)"
        
        var hardwareString = getSysInfo(byName: "hw.model")
        
        var sdkBundleInfoDictionary = TradeItBundleProvider.provide().infoDictionary
        
        var sdkName = sdkBundleInfoDictionary?["CFBundleName"] as? String
        var sdkVersion = sdkBundleInfoDictionary?["CFBundleShortVersionString"] as? String
        
        return "\(appDescriptor)/\(osDescriptor) (\(String(describing: hardwareString))) / \(sdkName ?? "")/\(sdkVersion ?? "")"
    }()
    
    private static func getSysInfo(byName typeSpecifier: String?) -> String? {
        var size: size_t
        sysctlbyname(typeSpecifier, nil, &size, nil, 0)
        
        let answer = malloc(size)
        sysctlbyname(typeSpecifier, answer, &size, nil, 0)
        
        let results = String(cString: &answer, encoding: .utf8)
        
        free(answer)
        return results
    }
    
}

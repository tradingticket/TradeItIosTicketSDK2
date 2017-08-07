import Foundation

@objc public protocol RequestFactory {
    func buildPostRequest(for url: URL, jsonPostBody parameters: String, headers: [String : String]) -> URLRequest
}

@objc public class DefaultRequestFactory: NSObject, RequestFactory {
    public func buildPostRequest(
        for url: URL,
        jsonPostBody: String,
        headers: [String : String]
        ) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpBody = jsonPostBody.data(using: .utf8)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers // TODO: Add Dictionary extension for merging dictionaries
        
        return request;
    }
}

@objc public class TradeItRequestFactory: NSObject {
    static var requestFactory: RequestFactory = DefaultRequestFactory()
    
    static func setRequestFactory(requestFactory: RequestFactory) {
        TradeItRequestFactory.requestFactory = requestFactory
    }
    
    private static var envToHostDict: [TradeitEmsEnvironments: String] = [
        TradeItEmsProductionEnv : "https://ems.tradingticket.com/",
        TradeItEmsTestEnv: "https://ems.qa.tradingticket.com/",
        TradeItEmsLocalEnv: "https://localhost:8443/"
    ]
    
    static func buildJsonRequest(for requestObject: JSONModel, emsAction: String, environment env: TradeitEmsEnvironments) -> URLRequest {
        let userAgent: String = TradeItUserAgentProvider.getUserAgent()
        let requestJsonString = requestObject.toJSONString() ?? ""
        let baseURL = TradeItRequestFactory.getBaseUrl(forEnvironment: env)
        guard let url = URL(string: emsAction, relativeTo: baseURL) else {
            preconditionFailure("TradeItIosTicketSDK ERROR building json request with url: \(baseURL?.absoluteString ?? ""), action: \(emsAction)")
        }
        let headers: [String: String] = ["Accept": "application/json", "Content-Type": "application/json", "User-Agent": userAgent]
        let request: URLRequest = TradeItRequestFactory.requestFactory.buildPostRequest(for: url, jsonPostBody: requestJsonString, headers: headers)
        return request
    }
    
    static func setHost(_ host: String, forEnvironment env: TradeitEmsEnvironments) {
        TradeItRequestFactory.envToHostDict[env] = host
    }
    
    static func getHostForEnvironment(_ env: TradeitEmsEnvironments) -> String {
        if let host = TradeItRequestFactory.envToHostDict[env] {
            return host
        }
        else {
            print("Invalid environment [\(env)] - directing to TradeIt production by default")
            return "https://ems.tradingticket.com/"
        }
    }
    
    // MARK: Private
    private static func getBaseUrl(forEnvironment env: TradeitEmsEnvironments) -> URL? {
        let version: TradeItEmsApiVersion = TradeItEmsApiVersion_2
        return TradeItRequestFactory.getBaseUrl(forEnvironment: env, version: version)
    }
    
    private static func getBaseUrl(forEnvironment env: TradeitEmsEnvironments, version: TradeItEmsApiVersion) -> URL? {
        var baseUrl: String = TradeItRequestFactory.getHostForEnvironment(env)
        let versionPath: String = TradeItRequestFactory.getApiPrefix(for: version)
        baseUrl = baseUrl + (versionPath)
        return URL(string: baseUrl)
    }
    
    private static func getApiPrefix(for version: TradeItEmsApiVersion) -> String {
        switch version {
        case TradeItEmsApiVersion_1:
            return "api/v1/"
        case TradeItEmsApiVersion_2:
            return "api/v2/"
        default:
            print("Invalid version \(version) - directing to v2 by default")
            return "api/v2/"
        }
    }
    
}

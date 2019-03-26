import Foundation

@objc public protocol RequestFactory {
    func buildPostRequest(forUrl url: URL, jsonPostBody parameters: String, headers: [String : String]) -> URLRequest
}

@objc public class DefaultRequestFactory: NSObject, RequestFactory {
    @objc public func buildPostRequest(
        forUrl url: URL,
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

// TODO: Why is this a RequestFactory when it does not implement
// the RequestFactory protocol? Need to think of a better name.
class TradeItRequestFactory: NSObject {
    static let JSON_ENCODER = JSONEncoder()
    static var requestFactory: RequestFactory = DefaultRequestFactory()
    
    static func setRequestFactory(requestFactory: RequestFactory) {
        TradeItRequestFactory.requestFactory = requestFactory
    }
    
    private static var envToHostDict: [TradeitEmsEnvironments: String] = [
        .tradeItEmsProductionEnv : "https://ems.tradingticket.com/",
        .tradeItEmsTestEnv: "https://ems.qa.tradingticket.com/",
        .tradeItEmsLocalEnv: "https://localhost:8080/"
    ]
    
    static func buildJsonRequest<T : Codable>(for requestObject: T, emsAction: String, environment env: TradeitEmsEnvironments) -> URLRequest {
        let userAgent: String = TradeItUserAgentProvider.userAgent
        var requestJsonString = ""
        do {
            let jsonData = try JSON_ENCODER.encode(requestObject)
            requestJsonString = String(data: jsonData, encoding: .utf8) ?? ""
        } catch {
            preconditionFailure("TradeItIosTicketSDK ERROR building json request for \(requestObject), error:  \(error)")
        }
        let baseURL = TradeItRequestFactory.getBaseUrl(forEnvironment: env)
        guard let url = URL(string: emsAction, relativeTo: baseURL) else {
            preconditionFailure("TradeItIosTicketSDK ERROR building json request with url: \(baseURL?.absoluteString ?? ""), action: \(emsAction)")
        }
        let headers: [String: String] = ["Accept": "application/json", "Content-Type": "application/json", "User-Agent": userAgent]
        let request: URLRequest = TradeItRequestFactory.requestFactory.buildPostRequest(forUrl: url, jsonPostBody: requestJsonString, headers: headers)
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
        let version: TradeItEmsApiVersion = TradeItEmsApiVersion._2
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
        case TradeItEmsApiVersion._1:
            return "api/v1/"
        case TradeItEmsApiVersion._2:
            return "api/v2/"
        default:
            print("Invalid version \(version) - directing to v2 by default")
            return "api/v2/"
        }
    }
    
}

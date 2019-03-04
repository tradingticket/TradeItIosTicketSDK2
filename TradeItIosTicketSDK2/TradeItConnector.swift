import PromiseKit

class TradeItConnector: NSObject {
    var apiKey: String
    var environment: TradeitEmsEnvironments
    var version: TradeItEmsApiVersion
    var session: URLSession
    
    static let BROKER_LIST_KEYNAME = "TRADEIT_BROKERS"
    static let USER_DEFAULTS_SUITE = "TRADEIT"
    
    private static let userDefaultsVar: UserDefaults? = {
        var userDefaults = UserDefaults(suiteName: USER_DEFAULTS_SUITE)
        return userDefaults
    }()
    
    static func userDefaults() -> UserDefaults? {
        return TradeItConnector.userDefaultsVar
    }
    
    init(apiKey: String, environment: TradeitEmsEnvironments, version: TradeItEmsApiVersion) {
        self.apiKey = apiKey
        self.environment = environment
        self.version = version
        self.session = URLSession(configuration: .default) // Swift compiler requires to initialize session directly in the constructor
        super.init()
        self.initSession()
    }
    
    init(apiKey: String) {
        self.apiKey = apiKey
        self.environment = TradeitEmsEnvironments.tradeItEmsProductionEnv
        self.version = TradeItEmsApiVersion._2
        self.session = URLSession(configuration: .default) // Swift compiler requires to initialize session directly in the constructor
        super.init()
        self.initSession()
    }
    
    
    func updateKeychain(withLink link: TradeItAuthLinkResult?, withBroker broker: String?, withBrokerLongName brokerLongName: String?) -> TradeItLinkedLogin? {
        let linkDict = getLinkedLoginDictByuserId(link?.userId)
        
        if let linkDict = linkDict {
            // If the saved link is found, update the token in the keychain for its keychainId
            let keychainId = linkDict["keychainId"] as? String
            
            TradeItKeychain.save(link?.userToken, forKey: keychainId)
            let label = linkDict["label"] as? String
            return TradeItLinkedLogin(
                label: label ?? "",
                broker: broker ?? "",
                brokerLongName: brokerLongName ?? "",
                userId: link?.userId ?? "",
                keychainId: keychainId ?? ""
            )
        } else {
            // No existing link for that userId so make a new one
            let authLinkResult = TradeItAuthLinkResult()
            authLinkResult.userId = link?.userId ?? ""
            authLinkResult.userToken = link?.userToken ?? ""
            return saveToKeychain(
                withLink: authLinkResult,
                withBroker: broker,
                withBrokerLongName: brokerLongName
            )
        }
    }
    
    func saveToKeychain(withLink link: TradeItAuthLinkResult?, withBroker broker: String?, withBrokerLongName brokerLongName: String?) -> TradeItLinkedLogin? {
        return saveToKeychain(withLink: link, withBroker: broker, withBrokerLongName: brokerLongName, andLabel: broker)
    }
    
    func saveToKeychain(withLink link: TradeItAuthLinkResult?, withBroker broker: String?, withBrokerLongName brokerLongName: String?, andLabel label: String?) -> TradeItLinkedLogin? {
        return saveToKeychain(withUserId: link?.userId, andUserToken: link?.userToken, andBroker: broker, andBrokerLongName: brokerLongName, andLabel: label)
    }
    
    func saveToKeychain(withUserId userId: String?, andUserToken userToken: String?, andBroker broker: String?, andBrokerLongName brokerLongName: String?, andLabel label: String?) -> TradeItLinkedLogin? {
        var accounts = getLinkedLoginsRaw()
        let keychainId = UUID().uuidString
        
        let newRecord = [
            "label": label ?? "",
            "broker": broker ?? "",
            "brokerLongName": brokerLongName ?? "",
            "userId": userId ?? "",
            "keychainId": keychainId
        ]
        
        accounts.append(newRecord)
        
        TradeItConnector.userDefaults()?.set(accounts, forKey: TradeItConnector.BROKER_LIST_KEYNAME)
        
        TradeItKeychain.save(userToken, forKey: keychainId)
        
        return TradeItLinkedLogin(
            label: label ?? "",
            broker: broker ?? "",
            brokerLongName: brokerLongName ?? "",
            userId: userId ?? "",
            keychainId: keychainId
        )
    }
    
    func getLinkedLoginDictByuserId(_ userId: String?) -> [AnyHashable : Any]? {
        let linkedLoginDicts = getLinkedLoginsRaw()
        
        // Search for the existing saved link by userId
        let filteredLinkDicts = linkedLoginDicts.filter { $0["userId"] == userId }
        
        if filteredLinkDicts.count > 0 {
            // Link found
            return filteredLinkDicts.first
        } else {
            // Link not found
            return nil
        }
    }
    
    func getLinkedLoginsRaw() -> [[String: String]] {
        var linkedAccounts = TradeItConnector.userDefaultsVar?.array(forKey: TradeItConnector.BROKER_LIST_KEYNAME)
        
        if linkedAccounts == nil {
            linkedAccounts = [[String : String]]()
        }
        
        /*
         NSLog(@"------------Linked Logins-------------");
         [linkedAccounts enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
         NSDictionary * account = (NSDictionary *) obj;
         NSLog(@"Broker: %@ - Label: %@ - UserId: %@ - KeychainId: %@", account[@"broker"], account[@"label"], account[@"userId"], account[@"keychainId"]);
         }];
         */
        
        return linkedAccounts as? [[String: String]] ?? []
    }
    
    func getLinkedLogins() -> [Any]? {
        let linkedAccounts = getLinkedLoginsRaw()
        
        var accountsToReturn: [TradeItLinkedLogin] = []
        for account: [String : String] in linkedAccounts {
            accountsToReturn.append(
                TradeItLinkedLogin(
                    label: account["label"] ?? "",
                    broker: account["broker"] ?? "",
                    brokerLongName: account["brokerLongName"] ?? account["broker"] ?? "",
                    userId: account["userId"] ?? "",
                    keychainId: account["keychainId"] ?? ""
                )
            )
        }
        
        return accountsToReturn
    }
    
    func deleteLocalLinkedLogin(_ login: TradeItLinkedLogin?) {
        var accounts = getLinkedLoginsRaw()
        var toRemove: [[String: String]] = []
        
        (accounts as NSArray).enumerateObjects({ obj, idx, stop in
            let account = obj as? [String : String] ?? [:]
            if (account["userId"] == login?.userId) {
                toRemove.append(account)
            }
        })
        
        accounts.removeAll { toRemove.contains($0)}
        
        TradeItConnector.userDefaultsVar?.set(accounts, forKey: TradeItConnector.BROKER_LIST_KEYNAME)
    }
    
    func userToken(fromKeychainId keychainId: String) -> String? {
        return TradeItKeychain.getStringForKey(keychainId)
    }
    
    func sendReturnJSON(
        _ request: URLRequest,
        withCompletionBlock completionBlock: @escaping (TradeItResult, String?) -> Void
        ) {
        self.send(request, withCompletionBlock: completionBlock)
    }
    
    func send<T: TradeItResult>(
        _ request: URLRequest,
        targetClassType: T.Type,
        withCompletionBlock completionBlock: @escaping (TradeItResult?) -> Void
        ) {
        self.send(request) { result, json in
            if result.isSuccessful() { // Try to cast to desired resultClass
                completionBlock(TradeItResultTransformer.transform(targetClassType: targetClassType, json: json))
            } else {
                completionBlock(result) // Review order or Security question or Error case
            }
        }
    }
    
    func send<T: TradeItResult>(
        _ request: URLRequest,
        targetClassType: T.Type
        ) -> Promise<T> {
        return Promise<T> { seal in
            send(request, targetClassType: targetClassType) { result in
                switch(result) {
                case let result as T: seal.fulfill(result)
                case let error as TradeItErrorResult: seal.reject(error)
                default:
                    seal.reject(
                        TradeItErrorResult.error(withSystemMessage: "The server returned a response that could not deserialize to the requested type: \(targetClassType.classForCoder())")
                    )
                }
            }
        }
    }
    
    // MARK: Private
    
    private func send(
        _ request: URLRequest,
        withCompletionBlock completionBlock: @escaping (TradeItResult, String?) -> Void
        ) {
        guard !TradeItSDK.isDeviceJailbroken else {
            completionBlock(
                TradeItErrorResult(
                    title: "This device is jailbroken",
                    message: "This action is not allowed on a jailbroken device"
                ), ""
            )
            return
        }
        
        if TradeItSDK.debug {
            let requestBodyString = String(data: request.httpBody ?? Data(), encoding: String.Encoding.utf8)
            print("\n===== REQUEST =====\n\(request.url?.absoluteString ?? "NO URL!")\n\(requestBodyString ?? "NO BODY!")\n")
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.session.dataTask(
                with: request,
                completionHandler: { data, response, error in
                    if TradeItSDK.debug {
                        let responseBodyString = String(data: data ?? Data(), encoding: String.Encoding.utf8)
                        print("\n===== RESPONSE =====\n\(request.url?.absoluteString ?? "NO URL!")\n\(responseBodyString ?? "NO BODY!")\n")
                        if let error = error {
                            print("Error: \(error.localizedDescription)")
                        }
                    }
                    
                    let (result, json) = self.processResponse(data, response, error)
                    
                    DispatchQueue.main.async { completionBlock(result, json) }
            }
                ).resume()
        }
    }
    
    private func processResponse(_ data: Data?, _ response: URLResponse?, _ error: Error?) -> (TradeItResult, String?) {
        guard let httpResponse = response as? HTTPURLResponse else {
            return (TradeItErrorResult.error(withSystemMessage: "Unable to cast response to HTTPUrlResponse. Error description message: \(error?.localizedDescription ?? "nil")"), nil)
        }
        
        guard httpResponse.statusCode == 200 else {
            return (TradeItErrorResult.error(withSystemMessage: "Response status code: \(httpResponse.statusCode)."), nil)
        }
        
        guard let data = data, let json = String(data: data, encoding: .utf8) else {
            return (TradeItErrorResult.error(withSystemMessage: "Unable to read JSON data."), nil)
        }
        
        var result = TradeItResultTransformer.transform(targetClassType: TradeItResult.self, json: json)
        
        if result?.isError() == true { // Server sent an ERROR response so try create a TradeItErrorResult
            result = TradeItResultTransformer.transform(targetClassType: TradeItErrorResult.self, json: json)
        } else if result?.isSecurityQuestion() == true {
            result = TradeItResultTransformer.transform(targetClassType: TradeItSecurityQuestionResult.self, json: json)
        }
        
        let defaultedResult = result ?? TradeItErrorResult.error(withSystemMessage: "JSON from server does not match the TradeItResult format.")
        
        return (defaultedResult, json)
    }
    
    private func initSession() {
        let configuration = URLSessionConfiguration.default
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        configuration.urlCache = nil
        session = URLSession(configuration: configuration)
    }
}

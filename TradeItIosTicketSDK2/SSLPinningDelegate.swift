import Foundation

@objc public class SSLPinningDelegate: NSObject, URLSessionDelegate {
    @objc public func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        let serverTrust = challenge.protectionSpace.serverTrust
        let certificate = SecTrustGetCertificateAtIndex(serverTrust!, 0)

        if(!isLocal() && isServerTrusted(challenge, serverTrust: serverTrust) && isSSLCertificateMatching(certificate)) {
            let credential:URLCredential = URLCredential(trust: serverTrust!)
            completionHandler(.useCredential, credential)
        } else {
            print("SSL Pinning: SSL certificate match failed. Try upgrading to the latest TradeItTicketSDK.")
            completionHandler(.cancelAuthenticationChallenge, nil)
        }
    }

    func isLocal() -> Bool {
        return TradeItSDK.environment == TradeItEmsLocalEnv
    }

    private func isServerTrusted(_ challenge: URLAuthenticationChallenge, serverTrust: SecTrust?) -> Bool {
        // Set SSL policies for domain name check
        let policies = NSMutableArray()
        policies.add(SecPolicyCreateSSL(true, (challenge.protectionSpace.host as CFString?)))
        SecTrustSetPolicies(serverTrust!, policies);

        // Evaluate server certificate
        var result: SecTrustResultType = SecTrustResultType.invalid
        SecTrustEvaluate(serverTrust!, &result)
        return (result == SecTrustResultType.unspecified || result == SecTrustResultType.proceed)
    }

    private func isSSLCertificateMatching(_ certificate: SecCertificate?) -> Bool {
        guard let certificate = certificate else {
            print("Certificate from the SSL request is missing.")
            return false
        }
        guard let pathToPinnedServerCertificate = pathToPinnedServerCertificate() else {
            print("Path to pinned server certificate is missing.")
            return false
        }
        guard let localCertificate : Data = try? Data(contentsOf: URL(fileURLWithPath: pathToPinnedServerCertificate)) else {
            print("Pinned SSL certificate is missing. Try upgrading to the latest TradeItAdSdk.")
            return false
        }

        let remoteCertificate:Data = SecCertificateCopyData(certificate) as Data
        return (remoteCertificate == localCertificate)
    }

    private func pathToPinnedServerCertificate() -> String? {
        let bundle = TradeItBundleProvider.provide()
        let file = { () -> String? in
            switch (TradeItSDK.environment) {
            case TradeItEmsProductionEnv: return "server-prod"
            case TradeItEmsTestEnv: return "server-qa"
            default: return nil
            }
        }()
        return bundle.path(forResource: file, ofType: "der")
    }
}

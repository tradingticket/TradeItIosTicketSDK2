import LocalAuthentication

class TradeItDeviceManager {
    func authenticateUserWithTouchId(onSuccess: @escaping () -> Void, onFailure: @escaping () -> Void) {
        var error: NSError?
        
        let context = LAContext()

        // If it is UITesting, it will bypass touch ID/security login
        if ProcessInfo.processInfo.arguments.contains("isUITesting") {
            print("UITesting: bypassing...")
            onSuccess()
            return
        }
        
        guard context.canEvaluatePolicy(LAPolicy.deviceOwnerAuthentication, error: &error) else {
            print("deviceOwnerAuthentication is not available on this device: \(error)")
            onSuccess()
            return
        }
        
        context.evaluatePolicy(
            LAPolicy.deviceOwnerAuthentication,
            localizedReason: "You must authorize before proceeding",
            reply: { success, evaluationError in
                if success {
                    print("deviceOwnerAuthentication: succeeded")
                    onSuccess()
                } else {
                    guard let error = evaluationError else {
                        print("deviceOwnerAuthentication: unknown failure")
                        onFailure()
                        return
                    }

                    switch error {
                    case LAError.authenticationFailed:
                        print("deviceOwnerAuthentication: invalid credentials")
                        onFailure()
                    case LAError.userCancel:
                        print("deviceOwnerAuthentication: cancelled by user")
                        onFailure()
                    case LAError.userFallback:
                        print("deviceOwnerAuthentication: user tapped the fallback button")
                        onFailure()
                    case LAError.systemCancel:
                        print("deviceOwnerAuthentication: canceled by system (another application went to foreground)")
                        onFailure()
                    case LAError.passcodeNotSet:
                        print("deviceOwnerAuthentication: passcode is not set")
                        onSuccess()
                    case LAError.touchIDNotAvailable:
                        print("deviceOwnerAuthentication: TouchID is not available on the device")
                        onSuccess()
                    case LAError.touchIDLockout:
                        print("deviceOwnerAuthentication: TouchID is locked out")
                        onFailure()
                    case LAError.appCancel:
                        print("deviceOwnerAuthentication: Authentication was canceled by application")
                        onFailure()
                    case LAError.invalidContext:
                        print("deviceOwnerAuthentication: LAContext passed to this call has been previously invalidated")
                        onFailure()
                    default:
                        print("deviceOwnerAuthentication: unknown failure")
                        onFailure()
                    }
                }
            }
        )
    }
    
}

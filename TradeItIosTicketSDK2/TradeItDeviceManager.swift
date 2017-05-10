import LocalAuthentication

class TradeItDeviceManager {
    func authenticateUserWithTouchId(onSuccess: @escaping () -> Void, onFailure: @escaping () -> Void) {
        var error: NSError?
        
        let context = LAContext()

        let onSuccessOnMainThread = {
            DispatchQueue.main.async { onSuccess() }
        }

        let onFailureOnMainThread = {
            DispatchQueue.main.async { onFailure() }
        }


        // If it is UITesting, it will bypass touch ID/security login
        if ProcessInfo.processInfo.arguments.contains("isUITesting") {
            print("UITesting: bypassing...")
            onSuccessOnMainThread()
            return
        }
        
        guard context.canEvaluatePolicy(LAPolicy.deviceOwnerAuthentication, error: &error) else {
            print("deviceOwnerAuthentication is not available on this device: \(error.debugDescription)")
            onSuccessOnMainThread()
            return
        }
        
        context.evaluatePolicy(
            LAPolicy.deviceOwnerAuthentication,
            localizedReason: "You must authorize before proceeding",
            reply: { success, evaluationError in
                if success {
                    print("deviceOwnerAuthentication: succeeded")
                    onSuccessOnMainThread()
                } else {
                    guard let error = evaluationError else {
                        print("deviceOwnerAuthentication: unknown failure")
                        onFailureOnMainThread()
                        return
                    }

                    switch error {
                    case LAError.authenticationFailed:
                        print("deviceOwnerAuthentication: invalid credentials")
                        onFailureOnMainThread()
                    case LAError.userCancel:
                        print("deviceOwnerAuthentication: cancelled by user")
                        onFailureOnMainThread()
                    case LAError.userFallback:
                        print("deviceOwnerAuthentication: user tapped the fallback button")
                        onFailureOnMainThread()
                    case LAError.systemCancel:
                        print("deviceOwnerAuthentication: canceled by system (another application went to foreground)")
                        onFailureOnMainThread()
                    case LAError.passcodeNotSet:
                        print("deviceOwnerAuthentication: passcode is not set")
                        onSuccessOnMainThread()
                    case LAError.touchIDNotAvailable:
                        print("deviceOwnerAuthentication: TouchID is not available on the device")
                        onSuccessOnMainThread()
                    case LAError.touchIDLockout:
                        print("deviceOwnerAuthentication: TouchID is locked out")
                        onFailureOnMainThread()
                    case LAError.appCancel:
                        print("deviceOwnerAuthentication: Authentication was canceled by application")
                        onFailureOnMainThread()
                    case LAError.invalidContext:
                        print("deviceOwnerAuthentication: LAContext passed to this call has been previously invalidated")
                        onFailureOnMainThread()
                    default:
                        print("deviceOwnerAuthentication: unknown failure")
                        onFailureOnMainThread()
                    }
                }
            }
        )
    }
    
}

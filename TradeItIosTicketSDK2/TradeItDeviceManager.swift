import LocalAuthentication

class TradeItDeviceManager {
    
    func authenticateUserWithTouchId(onSuccess onSuccess: () -> Void, onFailure: () -> Void) {
        var error: NSError?
        let myLocalizedReasonString = "Authentication is required"
        
        let context = LAContext()
        
        //If it is UITesting, it will bypass touch ID/security login
        if NSProcessInfo.processInfo().arguments.contains("isUITesting") {
            print("UITesting: bypassing...")
            onSuccess()
            return
        }
        
        guard context.canEvaluatePolicy(LAPolicy.DeviceOwnerAuthentication, error: &error) else {
            print("touch id not available on this device: \(error)")
            onSuccess()
            return
        }
        
        context.evaluatePolicy(
            LAPolicy.DeviceOwnerAuthentication,
            localizedReason: myLocalizedReasonString,
            reply: { (success: Bool, evaluationError: NSError?) -> Void in
            
            if success {
                print("authenticateUserWithTouchId succeeded")
                onSuccess()
            } else {
                guard let error = evaluationError else {
                    print("authenticateUserWithTouchId failed")
                    onFailure()
                    return
                }
                
                switch error.code {
                case LAError.AuthenticationFailed.rawValue:
                    print("Authentication failed: invalid credentials")
                    onFailure()
                case LAError.UserCancel.rawValue:
                    print("Authentication cancelled by the user")
                    onFailure()
                case LAError.UserFallback.rawValue:
                    print("User tapped the fallback button")
                    onFailure()
                case LAError.SystemCancel.rawValue:
                    print("Canceled by system (another application went to foreground)")
                    onFailure()
                case LAError.PasscodeNotSet.rawValue:
                    print("Passcode not set")
                    onSuccess()
                case LAError.TouchIDNotAvailable.rawValue:
                    print("Touch id not available on the device")
                    onSuccess()
                case LAError.TouchIDLockout.rawValue:
                    print("TouchIDLockout")
                    onFailure()
                case LAError.AppCancel.rawValue:
                    print("Authentication was canceled by application")
                    onFailure()
                case LAError.InvalidContext.rawValue:
                    print("LAContext passed to this call has been previously invalidated.")
                    onFailure()
                default:
                    print("Authentication failed")
                    onFailure()
                }
            }
            
        })
    }
    
}

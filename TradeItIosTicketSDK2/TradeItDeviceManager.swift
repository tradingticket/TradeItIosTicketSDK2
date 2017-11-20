import LocalAuthentication

class TradeItDeviceManager {
    
    private static let JAIL_BREAK_FILES = [
        "/Applications/Cydia.app",
        "/Applications/blackra1n.app",
        "/Applications/FakeCarrier.app",
        "/Applications/Icy.app",
        "/Applications/IntelliScreen.app",
        "/Applications/MxTube.app",
        "/Applications/RockApp.app",
        "/Applications/SBSettings.app",
        "/Applications/WinterBoard.app",
        "/Library/MobileSubstrate/MobileSubstrate.dylib",
        "/Library/MobileSubstrate/DynamicLibraries/LiveClock.plist",
        "/Library/MobileSubstrate/DynamicLibraries/Veency.plist",
        "/private/var/lib/apt",
        "/private/var/lib/cydia",
        "/private/var/mobile/Library/SBSettings/Themes",
        "/private/var/stash",
        "/private/var/tmp/cydia.log",
        "/System/Library/LaunchDaemons/com.ikey.bbot.plist",
        "/System/Library/LaunchDaemons/com.saurik.Cydia.Startup.plist",
        "/bin/bash",
        "/usr/bin/sshd",
        "/etc/apt",
        "/usr/libexec/sftp-server",
        "/usr/sbin/sshd"
    ]
    
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
    
    static func isDeviceJailBroken() -> Bool {
        guard TARGET_IPHONE_SIMULATOR != 1 else {
            return false
        }
        
        // Check 1 : existence of files that are common for jailbroken devices
        if !JAIL_BREAK_FILES.filter(FileManager.default.fileExists).isEmpty || UIApplication.shared.canOpenURL(URL(string:"cydia://package/com.example.package")!) {
            return true
        }
        
        // Check 2 : Reading and writing in system directories (sandbox violation)
        let stringToWrite = "Jailbreak Test"
        do {
            try stringToWrite.write(toFile: "/private/JailbreakTest.txt", atomically: true, encoding: String.Encoding.utf8)
            //Device is jailbroken
            return true
        } catch {
            return false
        }
    }
}

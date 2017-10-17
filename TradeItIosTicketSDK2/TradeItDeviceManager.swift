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
    
    static func isDeviceJailBroken() -> Bool {
        guard TARGET_IPHONE_SIMULATOR != 1 else {
            return false
        }
        
        // Check 1 : existence of files that are common for jailbroken devices
        if FileManager.default.fileExists(atPath: "/Applications/Cydia.app")
            || FileManager.default.fileExists(atPath: "/Applications/Cydia.app")
            || FileManager.default.fileExists(atPath: "/Applications/blackra1n.app")
            || FileManager.default.fileExists(atPath: "/Applications/FakeCarrier.app")
            || FileManager.default.fileExists(atPath: "/Applications/Icy.app")
            || FileManager.default.fileExists(atPath: "/Applications/IntelliScreen.app")
            || FileManager.default.fileExists(atPath: "/Applications/MxTube.app")
            || FileManager.default.fileExists(atPath: "/Applications/RockApp.app")
            || FileManager.default.fileExists(atPath: "/Applications/SBSettings.app")
            || FileManager.default.fileExists(atPath: "/Applications/WinterBoard.app")
            || FileManager.default.fileExists(atPath: "/Library/MobileSubstrate/MobileSubstrate.dylib")
            || FileManager.default.fileExists(atPath: "/Library/MobileSubstrate/DynamicLibraries/LiveClock.plist")
            || FileManager.default.fileExists(atPath: "/Library/MobileSubstrate/DynamicLibraries/Veency.plist")
            || FileManager.default.fileExists(atPath: "/private/var/lib/apt")
            || FileManager.default.fileExists(atPath: "/private/var/lib/cydia")
            || FileManager.default.fileExists(atPath: "/private/var/mobile/Library/SBSettings/Themes")
            || FileManager.default.fileExists(atPath: "/private/var/stash")
            || FileManager.default.fileExists(atPath: "/private/var/tmp/cydia.log")
            || FileManager.default.fileExists(atPath: "/System/Library/LaunchDaemons/com.ikey.bbot.plist")
            || FileManager.default.fileExists(atPath: "/System/Library/LaunchDaemons/com.saurik.Cydia.Startup.plist")
            || FileManager.default.fileExists(atPath: "/bin/bash")
            || FileManager.default.fileExists(atPath: "/usr/bin/sshd")
            || FileManager.default.fileExists(atPath: "/etc/apt")
            || FileManager.default.fileExists(atPath: "/usr/libexec/sftp-server")
            || FileManager.default.fileExists(atPath: "/usr/sbin/sshd")
            || UIApplication.shared.canOpenURL(URL(string:"cydia://package/com.example.package")!) {
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

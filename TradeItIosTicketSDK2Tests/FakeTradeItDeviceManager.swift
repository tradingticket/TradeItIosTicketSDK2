@testable import TradeItIosTicketSDK2

class FakeTradeItDeviceManager: TradeItDeviceManager {
    let calls = SpyRecorder()

    override func authenticateUserWithTouchId(onSuccess: @escaping () -> Void, onFailure: @escaping () -> Void) {
        self.calls.record(
            #function,
            args: [
                "onSuccess": onSuccess,
                "onFailure": onFailure
            ]
        )
        onSuccess()
    }
}

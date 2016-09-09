class MethodInvocation {
    let name: String
    let args: [String: Any]

    init(methodName: String, args: [String: Any]) {
        name = methodName
        self.args = args
    }
}

class SpyRecorder {
    private var methodInvocations = [MethodInvocation]()

    var all: [MethodInvocation] {
        return methodInvocations
    }

    var count: Int {
        return methodInvocations.count
    }

    func record(methodName: String, args: [String: Any] = [:]) {
        print("=====> SPY: Recording invocation for \(methodName) with args: \(args)")
        methodInvocations.append(MethodInvocation(methodName: methodName, args: args))
    }

    func forMethod(methodName: String) -> [MethodInvocation] {
        return methodInvocations.filter() {
            (invocation: MethodInvocation) in
            return invocation.name == methodName
        }
    }

    func reset() {
        methodInvocations = [MethodInvocation]()
    }
}

class Stubs {} // TODO: Implement me!

func flushAsyncEvents() {
    NSRunLoop.currentRunLoop().runUntilDate(NSDate())
}
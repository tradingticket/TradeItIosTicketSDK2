class MethodInvocation {
    let name: String
    let args: [Any]

    init(methodName: String, args: [Any]) {
        name = methodName
        self.args = args
    }
}

class InvocationStack {
    typealias InvocationStack = [MethodInvocation]

    private var methodInvocations = InvocationStack()

    func invoke(methodName: String, args: Any...) {
        methodInvocations.append(MethodInvocation(methodName: methodName, args: args))
    }

    func forMethod(methodName: String) -> [MethodInvocation] {
        return methodInvocations.filter() {
            (invocation: MethodInvocation) in
            return invocation.name == methodName
        }
    }

    func reset() {
        methodInvocations = InvocationStack()
    }
}

class Fake {
    let calls = InvocationStack()
}
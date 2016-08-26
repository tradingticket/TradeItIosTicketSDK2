import XCTest


extension XCTestCase {
    func predicateDoesntExist() -> NSPredicate {
        return NSPredicate(format: "exists == 0")
    }

    func predicateExists() -> NSPredicate {
        return NSPredicate(format: "exists == 1")
    }

    func predicateIsNotHittable() -> NSPredicate {
        return NSPredicate(format: "hittable == false")
    }

    func waitForAsyncElementToDisappear(element: XCUIElement, withinSeconds seconds: NSTimeInterval = 5) {
        usleep(100_000)
        self.expectationForPredicate(self.predicateDoesntExist(), evaluatedWithObject:element, handler: nil)
        self.waitForExpectationsWithTimeout(seconds, handler: nil)
    }

    func waitForAsyncElementToAppear(element: XCUIElement, withinSeconds seconds: NSTimeInterval = 5) {
        usleep(100_000)
        self.expectationForPredicate(self.predicateExists(), evaluatedWithObject:element, handler: nil)
        self.waitForExpectationsWithTimeout(seconds, handler: nil)
    }

    func waitForAsyncElementNotToBeHittable(element: XCUIElement, withinSeconds seconds: NSTimeInterval = 5) {
        usleep(100_000)
        self.expectationForPredicate(self.predicateIsNotHittable(), evaluatedWithObject:element, handler: nil)
        self.waitForExpectationsWithTimeout(seconds, handler: nil)
    }
}

class SpecHelper {

}
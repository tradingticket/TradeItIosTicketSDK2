import XCTest


extension XCTestCase {
    func predicateDoesntExist() -> NSPredicate {
        return NSPredicate(format: "exists == false")
    }

    func predicateExists() -> NSPredicate {
        return NSPredicate(format: "exists == true")
    }

    func predicateIsNotHittable() -> NSPredicate {
        return NSPredicate(format: "hittable == false")
    }

    func predicateIsHittable() -> NSPredicate {
        return NSPredicate(format: "hittable == true")
    }

    func predicateHasKeyboardFocus() -> NSPredicate {
        return NSPredicate(format:"hasKeyboardFocus == true")
    }

    func predicateNotHasKeyboardFocus() -> NSPredicate {
        return NSPredicate(format:"hasKeyboardFocus == false")
    }

    func waitForElementToDisappear(element: XCUIElement, withinSeconds seconds: NSTimeInterval = 5) {
        usleep(100_000)
        self.expectationForPredicate(self.predicateDoesntExist(), evaluatedWithObject:element, handler: nil)
        self.waitForExpectationsWithTimeout(seconds, handler: nil)
    }

    func waitForElementToAppear(element: XCUIElement, withinSeconds seconds: NSTimeInterval = 5) {
        usleep(100_000)
        self.expectationForPredicate(self.predicateExists(), evaluatedWithObject:element, handler: nil)
        self.waitForExpectationsWithTimeout(seconds, handler: nil)
    }

    func waitForElementNotToBeHittable(element: XCUIElement, withinSeconds seconds: NSTimeInterval = 5) {
        usleep(100_000)
        self.expectationForPredicate(self.predicateIsNotHittable(), evaluatedWithObject:element, handler: nil)
        self.waitForExpectationsWithTimeout(seconds, handler: nil)
    }

    func waitForElementToBeHittable(element: XCUIElement, withinSeconds seconds: NSTimeInterval = 5) {
        usleep(100_000)
        self.expectationForPredicate(self.predicateIsHittable(), evaluatedWithObject:element, handler: nil)
        self.waitForExpectationsWithTimeout(seconds, handler: nil)
    }

    func waitForElementToHaveKeyboardFocus(element: XCUIElement, withinSeconds seconds: NSTimeInterval = 5) {
        usleep(100_000)
        self.expectationForPredicate(self.predicateHasKeyboardFocus(), evaluatedWithObject:element, handler: nil)
        self.waitForExpectationsWithTimeout(seconds, handler: nil)
    }

    func waitForElementNotToHaveKeyboardFocus(element: XCUIElement, withinSeconds seconds: NSTimeInterval = 5) {
        usleep(100_000)
        self.expectationForPredicate(self.predicateNotHasKeyboardFocus(), evaluatedWithObject:element, handler: nil)
        self.waitForExpectationsWithTimeout(seconds, handler: nil)
    }
}

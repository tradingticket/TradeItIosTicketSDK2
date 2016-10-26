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

    func waitForElementToDisappear(_ element: XCUIElement, withinSeconds seconds: TimeInterval = 5) {
        usleep(100_000)
        self.expectation(for: self.predicateDoesntExist(), evaluatedWith:element, handler: nil)
        self.waitForExpectations(timeout: seconds, handler: nil)
    }

    func waitForElementToAppear(_ element: XCUIElement, withinSeconds seconds: TimeInterval = 5) {
        usleep(100_000)
        self.expectation(for: self.predicateExists(), evaluatedWith:element, handler: nil)
        self.waitForExpectations(timeout: seconds, handler: nil)
    }

    func waitForElementNotToBeHittable(_ element: XCUIElement, withinSeconds seconds: TimeInterval = 5) {
        usleep(100_000)
        self.expectation(for: self.predicateIsNotHittable(), evaluatedWith:element, handler: nil)
        self.waitForExpectations(timeout: seconds, handler: nil)
    }

    func waitForElementToBeHittable(_ element: XCUIElement, withinSeconds seconds: TimeInterval = 5) {
        usleep(100_000)
        self.expectation(for: self.predicateIsHittable(), evaluatedWith:element, handler: nil)
        self.waitForExpectations(timeout: seconds, handler: nil)
    }

    func waitForElementToHaveKeyboardFocus(_ element: XCUIElement, withinSeconds seconds: TimeInterval = 5) {
        usleep(100_000)
        self.expectation(for: self.predicateHasKeyboardFocus(), evaluatedWith:element, handler: nil)
        self.waitForExpectations(timeout: seconds, handler: nil)
    }

    func waitForElementNotToHaveKeyboardFocus(_ element: XCUIElement, withinSeconds seconds: TimeInterval = 5) {
        usleep(100_000)
        self.expectation(for: self.predicateNotHasKeyboardFocus(), evaluatedWith:element, handler: nil)
        self.waitForExpectations(timeout: seconds, handler: nil)
    }
}

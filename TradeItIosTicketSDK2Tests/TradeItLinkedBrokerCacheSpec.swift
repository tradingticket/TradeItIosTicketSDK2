import Quick
import Nimble

class TradeItLinkedBrokerCacheSpec: QuickSpec {
    override func spec() {
        var cache: TradeItLinkedBrokerCache

        beforeEach {
            // TODO: CLEAR NSUSERDEFAULTS
            cache = TradeItLinkedBrokerCache()
        }

        describe("cacheLinkedBroker") {
            context("") {
                it("") {
                    expect(linkedBrokerManager.linkedBrokers).to(beEmpty())
                }
            }

            context("") {
                it("") {

                }
            }
        }

        describe("loadLinkedBrokerFromCache") {

        }

        describe("clearLinkedBrokerFromCache") {

        }

        describe("clearCache") {

        }
    }
}

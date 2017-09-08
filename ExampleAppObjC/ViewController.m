#import "ViewController.h"
#import <TradeItIosTicketSDK2/TradeItIosTicketSDK2.h>
#import <TradeItIosTicketSDK2/TradeItIosTicketSDK2-Swift.h>

@interface ViewController ()

@end

@implementation ViewController

typedef void (^ _Nonnull PlaceOrder)(
    void (^ _Nonnull)(TradeItPlaceTradeResult * _Nonnull),
    void (^ _Nonnull)(TradeItErrorResult * _Nonnull)
);

- (void)viewDidLoad {
    [super viewDidLoad];
    [TradeItSDK configureWithApiKey:@"exampleapp-test-api-key"
                   oAuthCallbackUrl:[NSURL URLWithString:@"tradeItExampleObjCScheme://completeOAuth"]
                        environment:TradeItEmsTestEnv];
}

- (IBAction)linkBrokerTapped:(UIButton *)sender {
    [TradeItSDK.launcher launchBrokerLinkingFromViewController:self];
}

- (IBAction)tradeTapped:(UIButton *)sender {
    TradeItLinkedBroker *linkedBroker = [TradeItSDK.linkedBrokerManager linkedBrokers][0];
    [linkedBroker authenticateIfNeededOnSuccess:^{
        TradeItOrder *order = [[TradeItOrder alloc] init];
        order.linkedBrokerAccount = [linkedBroker accounts][0];
        order.symbol = @"CMG";
        order.action = TradeItOrderActionBuy;
        order.type = TradeItOrderPriceTypeMarket;
        order.quantity = [NSDecimalNumber decimalNumberWithString:@"1.0"];

        [order previewOnSuccess:^(TradeItPreviewTradeResult * _Nonnull previewResult, PlaceOrder placeOrder) {
            NSLog(@"%@", previewResult);

            placeOrder(^(TradeItPlaceTradeResult * _Nonnull placeTradeResult) {
                NSLog(@"%@", placeTradeResult);
            }, ^(TradeItErrorResult * _Nonnull error) {
                NSLog(@"%@", error);
            });
        } onFailure:^(TradeItErrorResult * _Nonnull error) {
            NSLog(@"%@", error);
        }];
    } onSecurityQuestion:^(TradeItSecurityQuestionResult * _Nonnull securityQuestion, void (^ _Nonnull onAnswer)(NSString * _Nonnull), void (^ _Nonnull onCancel)(void)) {
        // Handle Security Question
    } onFailure:^(TradeItErrorResult * _Nonnull error) {
        NSLog(@"%@", error);
    }];
}

@end

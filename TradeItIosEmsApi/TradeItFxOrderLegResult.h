#import <JSONModel/JSONModel.h>

@protocol TradeItFxOrderLegResult

@end

@interface TradeItFxOrderLegResult : JSONModel

@property (nonatomic, copy) NSString * _Nullable priceType;
@property (nonatomic, copy) NSString * _Nullable pair;
@property (nonatomic, copy) NSString * _Nullable action;
@property (nonatomic) NSInteger amount;
@property (nonatomic, copy) NSNumber<Optional> * _Nullable rate;
@property (nonatomic, copy) NSString * _Nullable orderNumber;
@property (nonatomic, copy) NSString * _Nullable orderStatus;
@property (nonatomic, copy) NSString * _Nullable orderStatusMessage;

@end

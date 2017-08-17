#import "YFLinearGradientView.h"

@implementation YFLinearGradientView

+ (Class)layerClass
{
    return [CAGradientLayer class];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        CAGradientLayer *layer = (CAGradientLayer *)self.layer;

        layer.colors = @[
             (id)[UIColor colorWithRed:0 green:0.23 blue:0.74 alpha:1.0].CGColor,
             (id)[UIColor colorWithRed:0.21 green:0.30 blue:0.8 alpha:1.0].CGColor,
             (id)[UIColor colorWithRed:0.25 green:0 blue:0.56 alpha:1.0].CGColor
        ];

        layer.locations = @[@0.0, @0.35, @1.0];

        layer.startPoint = CGPointMake(0.0, 0.5);

        layer.endPoint = CGPointMake(1.0, 0.5);
    }
    return self;
}

@end

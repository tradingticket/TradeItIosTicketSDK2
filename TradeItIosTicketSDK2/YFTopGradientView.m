#import "YFTopGradientView.h"

@implementation YFTopGradientView

+ (Class)layerClass
{
    return [CAGradientLayer class];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        CAGradientLayer *layer = (CAGradientLayer *)self.layer;

        layer.colors = @[ (id)[UIColor colorWithWhite:0.0 alpha:0.56].CGColor,
                          (id)[UIColor colorWithWhite:0.0 alpha:0.21].CGColor,
                          (id)[UIColor clearColor].CGColor ];

        layer.locations = @[ @0.0, @0.5, @0.85 ];

        layer.startPoint = CGPointMake(0.5, 0.0);

        layer.endPoint = CGPointMake(0.5, 1.0);
    }
    return self;
}

@end

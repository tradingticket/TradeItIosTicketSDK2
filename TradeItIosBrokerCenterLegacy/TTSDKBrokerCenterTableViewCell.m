//
//  TTSDKBrokerCenterTableViewCell.m
//  TradeItIosTicketSDK
//
//  Created by Daniel Vaughn on 5/9/16.
//  Copyright © 2016 Antonio Reyes. All rights reserved.
//

#import "TTSDKBrokerCenterTableViewCell.h"
//#import "TTSDKTradeItTicket.h"


@interface TTSDKBrokerCenterTableViewCell()

@property TradeItBrokerCenterBroker * data;
@property NSArray * disclaimerLabels;
@property UILabel * lastAttachedMessage;
@property (weak, nonatomic) IBOutlet UIButton *toggleExpanded;
@property (weak, nonatomic) IBOutlet UILabel *offerTitle;
@property (weak, nonatomic) IBOutlet UILabel *offerDescription;
@property (weak, nonatomic) IBOutlet UILabel *accountMinimum;
@property (weak, nonatomic) IBOutlet UILabel *optionsOffer;
@property (weak, nonatomic) IBOutlet UILabel *stocksEtfsOffer;
@property (weak, nonatomic) IBOutlet UIImageView *detailsArrow;
@property (weak, nonatomic) IBOutlet UILabel *optionsTitle;
@property (weak, nonatomic) IBOutlet UILabel *stocksEtfsTitle;
@property (weak, nonatomic) IBOutlet UILabel *featuresTitle;
@property (weak, nonatomic) IBOutlet UILabel *featureSlot1;
@property (weak, nonatomic) IBOutlet UILabel *featureSlot2;
@property (weak, nonatomic) IBOutlet UILabel *featureSlot3;
@property (weak, nonatomic) IBOutlet UILabel *featureSlot4;
@property (weak, nonatomic) IBOutlet UILabel *featureSlot5;
@property (weak, nonatomic) IBOutlet UILabel *featureSlot6;
@property (weak, nonatomic) IBOutlet UILabel *featureSlot7;
@property (weak, nonatomic) IBOutlet UILabel *featureSlot8;
@property (weak, nonatomic) IBOutlet UIImageView *logo;
@property (weak, nonatomic) IBOutlet UILabel *logoLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *logoHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *logoWidthConstraint;
@property (weak, nonatomic) IBOutlet UIButton *disclaimerButton;
@property (weak, nonatomic) IBOutlet UIView *disclaimerView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *disclaimerHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *leftFeaturesContainer;
@property (weak, nonatomic) IBOutlet UIView *rightFeaturesContainer;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftFeatureWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rightFeatureWidthConstraint;
@property (weak, nonatomic) IBOutlet UIView *expandedView;

@end


@implementation TTSDKBrokerCenterTableViewCell

static float kMessageSeparatorHeight = 10.0f;
static NSString * kBulletLayerName = @"circle_layer";

#pragma Mark Class methods

+(UIColor *) colorFromArray:(NSArray *)colorArray {
    NSNumber * red = [colorArray objectAtIndex:0];
    NSNumber * green = [colorArray objectAtIndex:1];
    NSNumber * blue = [colorArray objectAtIndex:2];
    NSNumber * alpha;
    
    if (colorArray.count > 3) {
        alpha = [colorArray objectAtIndex:3];
    } else {
        alpha = @1.0;
    }
    
    UIColor * color = [UIColor colorWithRed: [red floatValue]/255.0f  green:[green floatValue]/255.0f blue:[blue floatValue]/255.0f alpha:[alpha floatValue]];
    
    return color;
}


#pragma Mark Initialization

-(void) configureWithBroker:(TradeItBrokerCenterBroker *)broker {
    self.data = broker;

    [self populateSignupOffer];

    [self populateAccountMinimum];

    [self populateOptionsOffer];

    [self populateStocksEtfsOffer];

    [self populateFeatures: broker.features];

    self.disclaimerLabels = [[NSArray alloc] init];

    if (self.disclaimerToggled) {
        [self.disclaimerButton setTitle:@"CLOSE" forState:UIControlStateNormal];
        self.disclaimerHeightConstraint.constant = self.disclaimerLabelsTotalHeight;
    } else {
        [self.disclaimerButton setTitle:@"DISCLAIMER" forState:UIControlStateNormal];
        self.disclaimerHeightConstraint.constant = 0.0f;
    }

    [self populateStyles];
}


#pragma Mark Custom Styles

-(void) populateStyles {
    // SET COLORS
    
    UIColor * backgroundColor = [TTSDKBrokerCenterTableViewCell colorFromArray: self.data.backgroundColor];
    
    self.contentView.backgroundColor = backgroundColor;
    self.backgroundColor = backgroundColor;
    
    UIColor * textColor = [TTSDKBrokerCenterTableViewCell colorFromArray: self.data.textColor];
    
    self.offerTitle.textColor = textColor;
    self.offerDescription.textColor = textColor;
    self.accountMinimum.textColor = textColor;
    self.optionsOffer.textColor = textColor;
    self.optionsTitle.textColor = textColor;
    self.stocksEtfsOffer.textColor = textColor;
    self.stocksEtfsTitle.textColor = textColor;
    self.detailsArrow.image = [self.detailsArrow.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.detailsArrow.tintColor = textColor;
    self.featuresTitle.textColor = textColor;
    self.featureSlot1.textColor = textColor;
    self.featureSlot2.textColor = textColor;
    self.featureSlot3.textColor = textColor;
    self.featureSlot4.textColor = textColor;
    self.featureSlot5.textColor = textColor;
    self.featureSlot6.textColor = textColor;
    self.featureSlot7.textColor = textColor;
    self.featureSlot8.textColor = textColor;
    self.logoLabel.textColor = textColor;
    [self.disclaimerButton setTitleColor:textColor forState:UIControlStateNormal];
}

-(void) addBulletToLabel:(UILabel *)label withColor:(UIColor *)color {
    CAShapeLayer * circleLayer;

    for (CALayer * layer in label.layer.sublayers) {
        if ([layer.name isEqualToString: kBulletLayerName] && [layer isKindOfClass:CAShapeLayer.class]) {
            circleLayer = (CAShapeLayer *)layer;
        }
    }

    if (!circleLayer) {
        circleLayer = [CAShapeLayer layer];
        [circleLayer setPath:[[UIBezierPath bezierPathWithOvalInRect:CGRectMake(-5.0f, 5.0f, 2.0f, 2.0f)] CGPath]];
        [circleLayer setName: kBulletLayerName];
        [label.layer addSublayer: circleLayer];
    }

    [circleLayer setFillColor: color.CGColor];

    circleLayer.hidden = NO;
}

-(void) hideBulletInLabel:(UILabel *)label {
    for (CALayer * layer in label.layer.sublayers) {
        if ([layer.name isEqualToString: kBulletLayerName] && [layer isKindOfClass:CAShapeLayer.class]) {
            layer.hidden = YES;
        }
    }
}

-(void) addImage:(UIImage *)img {
    if (img) {
        self.logoLabel.hidden = YES;
        self.logoLabel.text = @"";

        self.logo.image = img;
        [self.logo layoutSubviews];
        
        // we need to determine the actual scale factor the image will use and then set the height constraint appropriately
        float scaleFactor = self.logoWidthConstraint.constant / img.size.width;
        float imageHeight = img.size.height * scaleFactor;
        self.logoHeightConstraint.constant = imageHeight;

    } else {
        self.logo.image = nil;
        self.logoLabel.hidden = NO;
        self.logoLabel.text = @"TODO: FIX";
    }
}

-(void) configureSelectedState:(BOOL)selected {
    if (selected) {
        self.detailsArrow.hidden = YES;
        self.expandedView.hidden = NO;
        self.promptButtonWebViewContainer.hidden = NO;

    } else {
        self.detailsArrow.hidden = NO;
        self.expandedView.hidden = YES;

        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        self.promptButtonWebViewContainer.hidden = YES;
        [CATransaction commit];
    }
}

-(void) configureDisclaimers:(UIView *)disclaimerView {
    for (UIView * view in self.disclaimerView.subviews) {
        [view removeFromSuperview];
    }

    self.disclaimerHeightConstraint.constant = self.disclaimerLabelsTotalHeight;

    [self.disclaimerView addSubview: disclaimerView];

    NSLayoutConstraint * topConstraint = [NSLayoutConstraint
                                          constraintWithItem:disclaimerView
                                          attribute:NSLayoutAttributeTop
                                          relatedBy:NSLayoutRelationEqual
                                          toItem:self.disclaimerView
                                          attribute:NSLayoutAttributeTopMargin
                                          multiplier:1
                                          constant:kMessageSeparatorHeight];
    topConstraint.priority = 900;

    NSLayoutConstraint * leftConstraint = [NSLayoutConstraint
                                           constraintWithItem:disclaimerView
                                           attribute:NSLayoutAttributeLeading
                                           relatedBy:NSLayoutRelationEqual
                                           toItem:self.disclaimerView
                                           attribute:NSLayoutAttributeLeadingMargin
                                           multiplier:1
                                           constant:0];
    leftConstraint.priority = 900;

    NSLayoutConstraint * rightConstraint = [NSLayoutConstraint
                                            constraintWithItem:disclaimerView
                                            attribute:NSLayoutAttributeTrailing
                                            relatedBy:NSLayoutRelationEqual
                                            toItem:self.disclaimerView
                                            attribute:NSLayoutAttributeTrailingMargin
                                            multiplier:1
                                            constant:0];
    rightConstraint.priority = 900;

    NSLayoutConstraint * bottomConstraint = [NSLayoutConstraint
                                            constraintWithItem:disclaimerView
                                            attribute:NSLayoutAttributeBottom
                                            relatedBy:NSLayoutRelationEqual
                                            toItem:self.disclaimerView
                                            attribute:NSLayoutAttributeBottomMargin
                                            multiplier:1
                                            constant:0];
    bottomConstraint.priority = 900;

    [self.disclaimerView addConstraint: topConstraint];
    [self.disclaimerView addConstraint: leftConstraint];
    [self.disclaimerView addConstraint: rightConstraint];
    [self.disclaimerView addConstraint: bottomConstraint];

    [self.disclaimerView setNeedsUpdateConstraints];

    [self layoutSubviews];
    [self layoutIfNeeded];
    [self layoutMargins];
    [self setNeedsDisplay];
    [self setNeedsLayout];
    [self setNeedsUpdateConstraints];
}

-(float) getMaxTextWidth:(UILabel *)label max:(float)max {
    float labelWidth = [label.text
                        boundingRectWithSize:label.frame.size
                        options:NSStringDrawingUsesDeviceMetrics
                        attributes:@{ NSFontAttributeName:label.font }
                        context:nil].size.width;
    
    if (labelWidth > max) {
        return labelWidth;
    } else {
        return max;
    }
}


#pragma Mark Populate data

-(void) populateSignupOffer {
    self.offerTitle.text = self.data.signupTitle;

    NSString * offerPostscript;

    if ([self.data.signupPostfix isEqualToString:@"asterisk"]) {
        offerPostscript = [NSString stringWithFormat:@"%C", 0x0000002A];
    } else if ([self.data.signupPostfix isEqualToString:@"dagger"]) {
        offerPostscript = [NSString stringWithFormat:@"%C", 0x00002020];
    } else {
        offerPostscript = @"";
    }

    self.offerDescription.text = [NSString stringWithFormat:@"%@%@", self.data.signupDescription, offerPostscript];
}

-(void) populateAccountMinimum {
    if (self.data.accountMinimum != nil) {
        self.accountMinimum.text = self.data.accountMinimum;
    } else {
        self.accountMinimum.text = @"";
    }
}

-(void) populateOptionsOffer {
    NSString * offerPostscript;
    
    if ([self.data.optionsPostfix isEqualToString:@"asterisk"]) {
        offerPostscript = [NSString stringWithFormat:@"%C", 0x0000002A];
    } else if ([self.data.optionsPostfix isEqualToString:@"dagger"]) {
        offerPostscript = [NSString stringWithFormat:@"%C", 0x00002020];
    } else {
        offerPostscript = @"";
    }

    self.optionsOffer.text = [NSString stringWithFormat:@"%@%@", self.data.optionsOffer, offerPostscript];
}

-(void) populateStocksEtfsOffer {
    NSString * offerPostscript;
    
    if ([self.data.stocksEtfsPostfix isEqualToString:@"asterisk"]) {
        offerPostscript = [NSString stringWithFormat:@"%C", 0x0000002A];
    } else if ([self.data.stocksEtfsPostfix isEqualToString:@"dagger"]) {
        offerPostscript = [NSString stringWithFormat:@"%C", 0x00002020];
    } else {
        offerPostscript = @"";
    }

    self.stocksEtfsOffer.text = [NSString stringWithFormat:@"%@%@", self.data.stocksEtfsOffer, offerPostscript];
}

-(void) populateFeatures:(NSArray *)features {
    // This is all very gross, but not sure of any other way to accomplish this
    if (!features || !features.count) {
        self.featureSlot1.text = @"";
        self.featureSlot2.text = @"";
        self.featureSlot3.text = @"";
        self.featureSlot4.text = @"";
        self.featureSlot5.text = @"";
        self.featureSlot6.text = @"";
        self.featureSlot7.text = @"";
        self.featureSlot8.text = @"";

        [self hideBulletInLabel:self.featureSlot1];
        [self hideBulletInLabel:self.featureSlot2];
        [self hideBulletInLabel:self.featureSlot3];
        [self hideBulletInLabel:self.featureSlot4];
        [self hideBulletInLabel:self.featureSlot5];
        [self hideBulletInLabel:self.featureSlot6];
        [self hideBulletInLabel:self.featureSlot7];
        [self hideBulletInLabel:self.featureSlot8];

        return;
    }

    int count = (int)features.count;

    float maxLeftFeatureWidth = 0.0f;
    float maxRightFeatureWidth = 0.0f;

    UIColor * textColor = [TTSDKBrokerCenterTableViewCell colorFromArray: self.data.textColor];

    self.featureSlot1.text = [features objectAtIndex:0];
    [self.featureSlot1 sizeToFit];
    maxLeftFeatureWidth = [self getMaxTextWidth:self.featureSlot1 max:maxLeftFeatureWidth];
    [self addBulletToLabel:self.featureSlot1 withColor:textColor];

    if (count > 1) {
        self.featureSlot2.text = [features objectAtIndex:1];
        [self.featureSlot2 sizeToFit];
        maxRightFeatureWidth = [self getMaxTextWidth:self.featureSlot2 max:maxRightFeatureWidth];
        [self addBulletToLabel:self.featureSlot2 withColor:textColor];
    } else {
        self.featureSlot2.text = @"";
        [self hideBulletInLabel:self.featureSlot2];
    }

    if (count > 2) {
        self.featureSlot3.text = [features objectAtIndex:2];
        [self.featureSlot3 sizeToFit];
        maxLeftFeatureWidth = [self getMaxTextWidth:self.featureSlot3 max:maxLeftFeatureWidth];
        [self addBulletToLabel:self.featureSlot3 withColor:textColor];
    } else {
        self.featureSlot3.text = @"";
        [self hideBulletInLabel:self.featureSlot3];
    }

    if (count > 3) {
        self.featureSlot4.text = [features objectAtIndex:3];
        [self.featureSlot4 sizeToFit];
        maxRightFeatureWidth = [self getMaxTextWidth:self.featureSlot4 max:maxRightFeatureWidth];
        [self addBulletToLabel:self.featureSlot4 withColor:textColor];
    } else {
        self.featureSlot4.text = @"";
        [self hideBulletInLabel:self.featureSlot4];
    }

    if (count > 4) {
        self.featureSlot5.text = [features objectAtIndex:4];
        [self.featureSlot5 sizeToFit];
        maxLeftFeatureWidth = [self getMaxTextWidth:self.featureSlot5 max:maxLeftFeatureWidth];
        [self addBulletToLabel:self.featureSlot5 withColor:textColor];
    } else {
        self.featureSlot5.text = @"";
        [self hideBulletInLabel:self.featureSlot5];
    }

    if (count > 5) {
        self.featureSlot6.text = [features objectAtIndex:5];
        [self.featureSlot6 sizeToFit];
        maxRightFeatureWidth = [self getMaxTextWidth:self.featureSlot6 max:maxRightFeatureWidth];
        [self addBulletToLabel:self.featureSlot6 withColor:textColor];
    } else {
        self.featureSlot6.text = @"";
        [self hideBulletInLabel:self.featureSlot6];
    }

    if (count > 6) {
        self.featureSlot7.text = [features objectAtIndex:6];
        [self.featureSlot7 sizeToFit];
        maxLeftFeatureWidth = [self getMaxTextWidth:self.featureSlot7 max:maxLeftFeatureWidth];
        [self addBulletToLabel:self.featureSlot7 withColor:textColor];
    } else {
        self.featureSlot7.text = @"";
        [self hideBulletInLabel:self.featureSlot7];
    }

    if (count > 7) {
        self.featureSlot8.text = [features objectAtIndex:7];
        [self.featureSlot8 sizeToFit];
        maxRightFeatureWidth = [self getMaxTextWidth:self.featureSlot8 max:maxRightFeatureWidth];
        [self addBulletToLabel:self.featureSlot8 withColor:textColor];
    } else {
        self.featureSlot8.text = @"";
        [self hideBulletInLabel:self.featureSlot8];
    }

    [self setNeedsUpdateConstraints];
    [self setNeedsLayout];
    [self layoutSubviews];

    // To account for bullet point (5px) and margin (8px)
    maxLeftFeatureWidth += 13.0f;
    maxRightFeatureWidth += 13.0f;

    float halfScreenWidth = [[UIScreen mainScreen] bounds].size.width / 2;

    if (maxLeftFeatureWidth > halfScreenWidth) {
        maxLeftFeatureWidth = halfScreenWidth - 13.0f;
        [self setLeftFeaturesToMultiLine:YES];
    } else {
        [self setLeftFeaturesToMultiLine:NO];
    }

    if (maxRightFeatureWidth > halfScreenWidth) {
        maxRightFeatureWidth = halfScreenWidth - 13.0f;
        [self setRightFeaturesToMultiLine:YES];
    } else {
        [self setRightFeaturesToMultiLine:NO];
    }

    self.leftFeatureWidthConstraint.constant = maxLeftFeatureWidth;
    self.rightFeatureWidthConstraint.constant = maxRightFeatureWidth;
}

-(void) setLeftFeaturesToMultiLine:(BOOL)multiLine {
    int lineNumber = multiLine ? 2 : 1;

    self.featureSlot1.numberOfLines = lineNumber;
    self.featureSlot3.numberOfLines = lineNumber;
    self.featureSlot5.numberOfLines = lineNumber;
    self.featureSlot7.numberOfLines = lineNumber;
}

-(void) setRightFeaturesToMultiLine:(BOOL)multiLine {
    int lineNumber = multiLine ? 2 : 1;

    self.featureSlot2.numberOfLines = lineNumber;
    self.featureSlot4.numberOfLines = lineNumber;
    self.featureSlot6.numberOfLines = lineNumber;
    self.featureSlot8.numberOfLines = lineNumber;
}


#pragma Mark Events

- (IBAction)toggleExpandedPressed:(id)sender {
    if ([self.delegate respondsToSelector:@selector(didToggleExpandedView:atIndexPath:)]) {
        [self.delegate didToggleExpandedView:!self.expandedViewToggled atIndexPath:self.indexPath];
    }
}

- (IBAction)promptPressed:(id)sender {
    if ([self.delegate respondsToSelector:@selector(didSelectLink:withTitle:)] && ![self.data.promptUrl isEqualToString:@""]) {
        // TODO: not sure what this prompt is doing
        //[self.delegate didSelectLink: self.data.promptUrl withTitle: [self.ticket getBrokerDisplayString: self.data.broker]];
    }
}

- (IBAction)disclaimerButtonPressed:(id)sender {
    self.disclaimerToggled = !self.disclaimerToggled;
    
    if ([self.delegate respondsToSelector:@selector(didSelectDisclaimer:withHeight:atIndexPath:)]) {
        [self.delegate didSelectDisclaimer:self.disclaimerToggled withHeight:self.disclaimerLabelsTotalHeight atIndexPath:self.indexPath];

        if (self.disclaimerToggled) {
            [self.disclaimerButton setTitle:@"CLOSE" forState:UIControlStateNormal];
        } else {
            [self.disclaimerButton setTitle:@"DISCLAIMER" forState:UIControlStateNormal];
        }
    }
}


@end

//
//  TTSDKBrokerCenterTableViewCell.h
//  TradeItIosTicketSDK
//
//  Created by Daniel Vaughn on 5/9/16.
//  Copyright © 2016 Antonio Reyes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TradeItBrokerCenterBroker.h"

@protocol TTSDKBrokerCenterDelegate;

@protocol TTSDKBrokerCenterDelegate <NSObject>

@required

-(void) didSelectLink:(NSString *)link withTitle:(NSString *)title;
-(void) didToggleExpandedView:(BOOL)toggled atIndexPath:(NSIndexPath *)indexPath;
-(void) didSelectDisclaimer:(BOOL)selected withHeight:(CGFloat)height atIndexPath:(NSIndexPath *)indexPath;

@end

@interface TTSDKBrokerCenterTableViewCell : UITableViewCell

@property (nonatomic, weak) id<TTSDKBrokerCenterDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIView *promptButtonWebViewContainer;
@property CGFloat disclaimerLabelsTotalHeight;
@property NSIndexPath * indexPath;
@property BOOL expandedViewToggled;
@property BOOL disclaimerToggled;
@property BOOL buttonWebviewLoaded;
@property (weak, nonatomic) IBOutlet UIWebView *webView;

+(UIColor *) colorFromArray:(NSArray *)colorArray;
-(void) configureWithBroker:(TradeItBrokerCenterBroker *)broker;
-(void) configureSelectedState:(BOOL)selected;
-(void) configureDisclaimers:(UIView *)disclaimerView;
-(void) addImage:(UIImage *)img;

@end
